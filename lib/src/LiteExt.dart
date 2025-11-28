part of 'sql.dart';

/// Bare columns in an aggregate query
/// distinct on
/// SELECT a, b, max(c) FROM tab1 GROUP BY a;
/// min/max 在聚合查询时,  会返回包含min/max值的行.
/// 利用这特特性, 可以实现postgresql distinct on 的特性
/// https://sqlite.org/lang_select.html#bareagg
/// https://sqlite.org/lang_select.html
extension LiteSqlInsertExt on LiteSQL {
  /// query([], from:Person)
  /// query(["*"], from:Person)
  /// query([Person.values], from:Person)
  ResultSet query(
    List<Object> columns, {
    required Object from,
    Object? where,
    Object? groupBy,
    Object? having,
    Object? window,
    Object? orderBy,
    int? limit,
    int? offset,
    List<dynamic>? args,
  }) {
    Express e = SELECT(columns).FROM(from);
    if (where != null) e = e.WHERE(where);
    if (groupBy != null) e = e.GROUP_BY(groupBy);
    if (having != null) e = e.HAVING(having);
    if (window != null) e = e.WINDOWS(window);
    if (orderBy != null) e = e.ORDER_BY(orderBy);
    if (limit != null) {
      e = e.LIMIT(limit);
      if (offset != null) e = e.OFFSET(offset);
    }
    e.addArgs(args);
    return e.query(this);
  }

  int insert(Object table, {required Iterable<ColumnValue> values, InsertOption? conflict, Returning? returning}) {
    assert(values.isNotEmpty);
    return insertValues(table, columns: values.map((e) => e.key), values: values.map((e) => e.value), conflict: conflict, returning: returning);
  }

  int insertMap(Object table, {required Map<Object, dynamic> values, InsertOption? conflict, Returning? returning}) {
    return insert(table, values: values.entries, conflict: conflict, returning: returning);
  }

  int insertValues(Object table, {required Iterable<Object> columns, required Iterable<dynamic> values, InsertOption? conflict, Returning? returning}) {
    assert(columns.isNotEmpty && values.isNotEmpty && columns.length == values.length);
    SpaceBuffer buf = _insertBuffer(table, columns);
    this.lastInsertRowId = 0;
    if (LiteSQL._supportReturning && returning != null) {
      buf << returning.clause;
      ResultSet rs = this.rawQuery(buf.toString(), values.toList());
      returning.returnRows.addAll(rs.listRows());
    } else {
      this.execute(buf.toString(), values.toList());
    }
    return this.lastInsertRowId;
  }

  List<int> insertAll(Object table, {required Iterable<Iterable<ColumnValue>> rows, InsertOption? conflict, Returning? returning}) {
    assert(rows.isNotEmpty);
    return insertAllValues(
      table,
      columns: rows.first.map((e) => e.key),
      rows: rows.map((row) => row.map((e) => e.value)),
      conflict: conflict,
      returning: returning,
    );
  }

  List<int> insertAllMap(Object table, {required Iterable<Map<Object, dynamic>> rows, InsertOption? conflict, Returning? returning}) {
    return insertAll(table, rows: rows.map((e) => e.entries), conflict: conflict, returning: returning);
  }

  List<int> insertAllValues(
    Object table, {
    required Iterable<Object> columns,
    required Iterable<Iterable<dynamic>> rows,
    InsertOption? conflict,
    Returning? returning,
  }) {
    assert(columns.isNotEmpty && rows.isNotEmpty);
    SpaceBuffer buf = _insertBuffer(table, columns);
    bool needReturn = LiteSQL._supportReturning && returning != null;
    if (needReturn) {
      buf << returning.clause;
    }
    PreparedStatement ps = prepareSQL(buf.toString());
    List<int> idList = [];
    for (Iterable<dynamic> values in rows) {
      this.lastInsertRowId = 0;
      if (needReturn) {
        ResultSet rs = ps.select(values.toList());
        returning.returnRows.addAll(rs.listRows());
      } else {
        ps.execute(values.toList());
      }
      idList.add(this.lastInsertRowId);
    }
    ps.close();
    return idList;
  }

  int upsert(Object table, {required Iterable<ColumnValue> values, required Iterable<Object> constraints, InsertOption? conflict, Returning? returning}) {
    assert(values.isNotEmpty);
    return upsertValues(table, columns: values.map((e) => e.key), constraints: constraints, values: values.map((e) => e.value), conflict: conflict, returning: returning);
  }

  int upsertMap(Object table, {required Map<Object, dynamic> values, required Iterable<Object> constraints, InsertOption? conflict, Returning? returning}) {
    return upsert(table, values: values.entries, constraints: constraints, conflict: conflict, returning: returning);
  }

  int upsertValues(
    Object table, {
    required Iterable<Object> columns,
    required Iterable<Object> constraints,
    required Iterable<dynamic> values,
    InsertOption? conflict,
    Returning? returning,
  }) {
    assert(columns.isNotEmpty && columns.length == values.length);
    if (constraints.isEmpty) {
      constraints = columns.filter((e) {
        if (e is TableColumn) {
          var p = e.proto;
          return p.primaryKey || p.unique;
        } else {
          return false;
        }
      });
    }

    List<dynamic> valueList = (values is List<dynamic>) ? values : values.toList();

    List<String> columnNames = columns.mapList((e) => _columnNameOf(e));
    List<String> constraintNames = constraints.mapList((e) => _columnNameOf(e));
    List<String> otherNames = columnNames.filter((e) => !constraintNames.contains(e));
    SpaceBuffer buf = _upsertBuffer(table, columnNames, constraints: constraintNames, otherColumns: otherNames, conflict: conflict);
    var argList = [...values, ...otherNames.mapList((e) => valueList[columnNames.indexOf(e)])];
    lastInsertRowId = 0;
    if (LiteSQL._supportReturning && returning != null) {
      buf << returning.clause;
      ResultSet rs = rawQuery(buf.toString(), argList);
      returning.returnRows.addAll(rs.listRows());
    } else {
      execute(buf.toString(), argList);
    }
    return lastInsertRowId;
  }

  List<int> upsertAll(Object table, {required List<List<ColumnValue>> rows, required Iterable<Object> constraints, InsertOption? conflict, Returning? returning}) {
    return upsertAllValues(
      table,
      columns: rows.first.map((e) => e.key),
      constraints: constraints,
      rows: rows.mapList((e) => e.mapList((x) => x.value)),
      conflict: conflict,
      returning: returning,
    );
  }

  List<int> upsertAllMap(Object table, {required List<Map<Object, dynamic>> rows, required Iterable<Object> constraints, InsertOption? conflict, Returning? returning}) {
    return upsertAll(table, rows: rows.mapList((e) => e.entries.toList()), constraints: constraints, conflict: conflict, returning: returning);
  }

  List<int> upsertAllValues(
    Object table, {
    required Iterable<Object> columns,
    required Iterable<Object> constraints,
    required List<List<dynamic>> rows,
    InsertOption? conflict,
    Returning? returning,
  }) {
    assert(columns.isNotEmpty && rows.isNotEmpty && columns.length == rows[0].length);
    if (constraints.isEmpty) {
      constraints = columns.filter((e) {
        if (e is TableColumn) {
          var p = e.proto;
          return p.primaryKey || p.unique;
        } else {
          return false;
        }
      });
    }

    List<String> columnNames = columns.mapList((e) => _columnNameOf(e));
    List<String> constraintNames = constraints.mapList((e) => _columnNameOf(e));
    List<String> otherNames = columnNames.filter((e) => !constraintNames.contains(e));
    SpaceBuffer buf = _upsertBuffer(table, columnNames, constraints: constraintNames, otherColumns: otherNames, conflict: conflict);
    bool needRet = LiteSQL._supportReturning && returning != null;
    if (needRet) {
      buf << returning.clause;
    }
    PreparedStatement ps = prepareSQL(buf.toString());
    List<int> idList = [];
    for (List<dynamic> row in rows) {
      var argList = [...row, ...otherNames.mapList((e) => row[columnNames.indexOf(e)])];
      lastInsertRowId = 0;
      if (needRet) {
        ResultSet rs = ps.select(argList);
        returning.returnRows.addAll(rs.listRows());
      } else {
        ps.execute(argList);
      }
      idList.add(lastInsertRowId);
    }
    ps.close();
    return idList;
  }

  int delete(Object table, {required Where where, Returning? returning}) {
    assert(where.isNotEmpty);
    SpaceBuffer buf = SpaceBuffer("DELETE FROM");
    buf << _tableNameOf(table).escapeSQL;
    buf << "WHERE";
    buf << where.sql;
    if (LiteSQL._supportReturning && returning != null) {
      buf << returning.clause;
      ResultSet rs = rawQuery(buf.toString(), where.args);
      returning.returnRows.addAll(rs.listRows());
    } else {
      execute(buf.toString(), where.args);
    }
    return updatedRows;
  }

  int update(Object table, {required Iterable<ColumnValue> values, required Where where, Returning? returning}) {
    return updateValues(table, columns: values.map((e) => e.key), values: values.map((e) => e.value), where: where, returning: returning);
  }

  int updateMap(Object table, {required Map<Object, dynamic> values, required Where where, Returning? returning}) {
    return update(table, values: values.entries, where: where, returning: returning);
  }

  int updateValues(Object table, {required Iterable<Object> columns, required Iterable<dynamic> values, required Where where, Returning? returning}) {
    assert(columns.isNotEmpty && columns.length == values.length);

    SpaceBuffer buf = SpaceBuffer("UPDATE");
    buf << _tableNameOf(table).escapeSQL;
    buf << "SET";
    buf << columns.map((e) => "${_columnNameOf(e)}=?").join(", ");
    buf << "WHERE";
    buf << where.sql;
    var argList = <dynamic>[...values, ...(where.args)];
    if (LiteSQL._supportReturning && returning != null) {
      buf << returning.clause;
      ResultSet rs = rawQuery(buf.toString(), argList);
      returning.returnRows.addAll(rs.listRows());
    } else {
      execute(buf.toString(), argList);
    }
    return updatedRows;
  }

  void dump(Type table) {
    dumpTable(_tableNameOf(table));
  }
}

extension on ColumnValue {
  String get keyName => _columnNameOf(key);
}

String _columnNameOf(Object col) {
  switch (col) {
    case String s:
      return s;
    case TableColumn c:
      return c.columnName;
  }
  errorSQL("Unknown key: $col ");
}

String _tableNameOf(Object table) {
  switch (table) {
    case String s:
      return s;
    case Type t:
      if (t == Object) errorSQL("NO table name");
      return "$t";
  }
  errorSQL("Unknown table: $table ");
}

SpaceBuffer _insertBuffer(Object table, Iterable<Object> columns, {InsertOption? conflict}) {
  SpaceBuffer buf = SpaceBuffer("INSERT");
  if (conflict != null) {
    buf << "OR" << conflict.conflict;
  }
  buf << "INTO" << _tableNameOf(table).escapeSQL;
  buf << "(";
  buf << columns.map((e) => _columnNameOf(e).escapeSQL).join(",");
  buf << ") VALUES(";
  buf << columns.map((e) => '?').join(",");
  buf << ")";
  return buf;
}

SpaceBuffer _upsertBuffer(
  Object table,
  Iterable<String> columns, {
  required Iterable<String> constraints,
  required Iterable<String> otherColumns,
  InsertOption? conflict,
}) {
  // List<String> otherColumns = columns.filter((e) => !constraints.contains(e));
  SpaceBuffer buf = SpaceBuffer("INSERT");
  if (conflict != null) {
    buf << "OR" << conflict.conflict;
  }
  buf << "INTO" << _tableNameOf(table).escapeSQL;
  buf << "(";
  buf << columns.map((e) => e.escapeSQL).join(",");
  buf << ") VALUES(";
  buf << columns.map((e) => '?').join(",");
  buf << ")";
  if (constraints.isNotEmpty) {
    buf << "ON CONFLICT(";
    buf << constraints.map((e) => e.escapeSQL).join(", ");
    if (otherColumns.isEmpty) {
      buf << ") DO NOTHING";
    } else {
      buf << ") DO UPDATE SET";
      buf << otherColumns.map((e) => "${e.escapeSQL}=?").join(", ");
    }
  }
  return buf;
}
