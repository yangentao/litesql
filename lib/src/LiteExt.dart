part of 'sql.dart';

extension LiteSqlInsertExt on LiteSQL {
  /// distinct on
  /// SELECT a, b, max(c) FROM tab1 GROUP BY a;
  /// min/max 在聚合查询时,  会返回包含min/max值的行.
  /// 利用这特特性, 可以实现postgresql distinct on 的特性
  /// //https://sqlite.org/lang_select.html#bareagg
  /// https://sqlite.org/lang_select.html
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

  int insert(Object table, Iterable<ColumnValue> values, {InsertOption? conflict, Returning? returning}) {
    assert(values.isNotEmpty);
    return insertValues(table, values.map((e) => e.key), values.map((e) => e.value), conflict: conflict, returning: returning);
  }

  int insertMap(Object table, Map<Object, dynamic> map, {InsertOption? conflict, Returning? returning}) {
    return insert(table, map.entries, conflict: conflict, returning: returning);
  }

  int insertValues(Object table, Iterable<Object> columns, Iterable<dynamic> values, {InsertOption? conflict, Returning? returning}) {
    assert(columns.isNotEmpty && values.isNotEmpty && columns.length == values.length);
    SpaceBuffer buf = _insertBuffer(table, columns);
    this.lastInsertRowId = 0;
    if (LiteSQL._supportReturning && returning != null) {
      buf << returning.clause;
      ResultSet rs = this.rawQuery(buf.toString(), values.toList());
      returning.returnRows.addAll(rs.allRows());
    } else {
      this.execute(buf.toString(), values.toList());
    }
    return this.lastInsertRowId;
  }

  List<int> insertAll(Object table, Iterable<Iterable<ColumnValue>> allValues, {InsertOption? conflict, Returning? returning}) {
    assert(allValues.isNotEmpty);
    return insertAllValues(table, allValues.first.map((e) => e.key), allValues.map((row) => row.map((e) => e.value)), conflict: conflict, returning: returning);
  }

  List<int> insertAllMap(Object table, Iterable<Map<Object, dynamic>> allMap, {InsertOption? conflict, Returning? returning}) {
    return insertAll(table, allMap.map((e) => e.entries), conflict: conflict, returning: returning);
  }

  List<int> insertAllValues(Object table, Iterable<Object> columns, Iterable<Iterable<dynamic>> allValues, {InsertOption? conflict, Returning? returning}) {
    assert(columns.isNotEmpty && allValues.isNotEmpty);
    SpaceBuffer buf = _insertBuffer(table, columns);
    bool needReturn = LiteSQL._supportReturning && returning != null;
    if (needReturn) {
      buf << returning.clause;
    }
    PreparedStatement ps = prepareSQL(buf.toString());
    List<int> idList = [];
    for (Iterable<dynamic> values in allValues) {
      this.lastInsertRowId = 0;
      if (needReturn) {
        ResultSet rs = ps.select(values.toList());
        returning.returnRows.addAll(rs.allRows());
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

  int upsertMap(Object table, {required Map<Object, dynamic> map, required Iterable<Object> constraints, InsertOption? conflict, Returning? returning}) {
    return upsert(table, values: map.entries, constraints: constraints, conflict: conflict, returning: returning);
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
      returning.returnRows.addAll(rs.allRows());
    } else {
      execute(buf.toString(), argList);
    }
    return lastInsertRowId;
  }

  List<int> upsertAll(Object table, {required List<List<ColumnValue>> values, required Iterable<Object> constraints, InsertOption? conflict, Returning? returning}) {
    return upsertAllValues(
      table,
      columns: values.first.map((e) => e.key),
      constraints: constraints,
      rows: values.mapList((e) => e.mapList((x) => x.value)),
      conflict: conflict,
      returning: returning,
    );
  }

  List<int> upsertAllMap(Object table, {required List<Map<Object, dynamic>> maps, required Iterable<Object> constraints, InsertOption? conflict, Returning? returning}) {
    return upsertAll(table, values: maps.mapList((e) => e.entries.toList()), constraints: constraints, conflict: conflict, returning: returning);
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
        returning.returnRows.addAll(rs.allRows());
      } else {
        ps.execute(argList);
      }
      idList.add(lastInsertRowId);
    }
    ps.close();
    return idList;
  }

  /// Returning ret = Returning.ALL;
  /// int n = lite.delete("stu", where: "id=1", returning: ret);
  /// println("del count: ", n); // 1
  /// println(ret.returnRows); // [{id: 1, name: yang}]
  int delete(String table, {required String where, AnyList? args, Returning? returning}) {
    assert(where.isNotEmpty);
    String sql = "DELETE FROM ${table.escapeSQL} WHERE $where";
    if (LiteSQL._supportReturning && returning != null) {
      sql += returning.clause;
      ResultSet rs = rawQuery(sql, args);
      returning.returnRows.addAll(rs.allRows());
    } else {
      execute(sql, args);
    }
    return updatedRows;
  }

  ///  Returning ret = Returning(["name"]);
  ///  int n  = lite.update("stu", ["name" >> "yangentao"], where: "id=1", returning: ret);
  ///  println("update count: ", n ); // 1
  ///  println(ret.returnRows); // [{name: yangentao}]
  int update(String table, List<LabelValue<dynamic>> values, {String? where, AnyList? args, Returning? returning}) {
    return updateBy(table, values.mapList((e) => (e.label, e.value)), where: where, args: args, returning: returning);
  }

  /// int n = update("person", [("name", "entao"), ("addr", "Peiking")]);
  int updateBy(String table, List<(String, dynamic)> values, {String? where, AnyList? args, Returning? returning}) {
    assert(values.isNotEmpty);
    var argList = <dynamic>[...values.mapList((e) => e.$2), ...?args];

    String sql = "UPDATE ${table.escapeSQL} SET ${values.map((e) => "${e.$1.escapeSQL} = ?").join(", ")}";
    if (notBlank(where)) {
      sql += " WHERE $where";
    }
    if (LiteSQL._supportReturning && returning != null) {
      sql += returning.clause;
      ResultSet rs = rawQuery(sql, argList);
      returning.returnRows.addAll(rs.allRows());
    } else {
      execute(sql, argList);
    }
    return updatedRows;
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
