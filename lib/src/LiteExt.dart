part of 'sql.dart';

extension LiteSqlInsertExt on LiteSQL {
  /// distinct on
  /// SELECT a, b, max(c) FROM tab1 GROUP BY a;
  /// min/max 在聚合查询时,  会返回包含min/max值的行.
  /// 利用这特特性, 可以实现postgresql distinct on 的特性
  /// //https://sqlite.org/lang_select.html#bareagg
  /// https://sqlite.org/lang_select.html
  ResultSet query(
    List<String>? columns, {
    required String from,
    String? where,
    String? groupBy,
    String? having,
    String? window,
    String? orderBy,
    List<String>? orders,
    int? limit,
    int? offset,
    List<dynamic>? args,
  }) {
    String sels = columns?.filter((e) => e.trim().isNotEmpty).map((e) => e.escapeSQL).join(", ") ?? "";
    if (sels.trim().isEmpty) {
      sels = "*";
    }
    SpaceBuffer buf = SpaceBuffer("SELECT");
    buf << sels << "FROM" << from.escapeSQL;
    if (where.notBlank) {
      buf << "WHERE" << where!;
    }
    if (groupBy.notBlank) {
      buf << "GROUP BY" << groupBy!;
      if (having.notBlank) {
        buf << "HAVING" << having!;
      }
    }
    if (window.notBlank) {
      buf << "WINDOW" << window!;
    }
    List<String> os = [?orderBy, ...?orders].filter((e) => e.trim().isNotEmpty);
    if (os.isNotEmpty) {
      buf << "ORDER BY" << os.join(", ");
    }
    if (limit != null) {
      buf << "LIMIT" << limit.toString();
      if (offset != null) {
        buf << "OFFSET" << offset.toString();
      }
    }
    return rawQuery(buf.toString(), args);
  }

  ///  Returning ret = Returning.ALL;
  ///  int id = lite.insertPairs("stu", ["name" >> "tom"], returning: ret ); // INSERT  INTO stu (name) VALUES (?)  RETURNING *
  ///  println("insert id: ", id); // 4
  ///  println(ret.returnRows); // [{id: 4, name: tom}]
  int insert(String table, List<LabelValue<dynamic>> values, {InsertOption? conflict, Returning? returning}) {
    assert(values.isNotEmpty);
    String cs = conflict == null ? "" : "OR ${conflict.conflict}";
    String sql = "INSERT $cs INTO ${table.escapeSQL} (${values.map((e) => e.label.escapeSQL).join(",")}) VALUES (${values.map((e) => '?').join(",")})";
    var args = values.mapList((e) => e.value);
    lastInsertRowId = 0;
    if (LiteSQL._supportReturning && returning != null) {
      sql += returning.clause;
      ResultSet rs = rawQuery(sql, args);
      returning.returnRows.addAll(rs.allRows());
    } else {
      execute(sql, args);
    }
    return lastInsertRowId;
  }

  int insertBy(String table, List<(String, dynamic)> values, {InsertOption? conflict, Returning? returning}) {
    return insert(table, values.mapList((e) => LabelValue(e.$1, e.$2)), conflict: conflict, returning: returning);
  }

  ///   Returning rr = Returning(["*"]);
  ///   List < int > idList = lite.insertRows("stu", [
  ///     ["name" >> 'yang'],
  ///     ["name" >> 'en'],
  ///     ["name" >> 'tao'],
  ///   ], returning: rr);
  ///
  ///   println("idList: ", idList); // [1, 2, 3]
  ///   println("returning: ", rr.returnRows); // [{id: 1, name: yang}, {id: 2, name: en}, {id: 3, name: tao}]
  List<int> insertRows(String table, List<List<LabelValue<dynamic>>> rows, {InsertOption? conflict, Returning? returning}) {
    if (rows.isEmpty) return List.empty();
    var firstRow = rows.first;
    String cs = conflict == null ? "" : "OR ${conflict.conflict}";
    String sql = "INSERT $cs INTO ${table.escapeSQL} (${firstRow.map((e) => e.label.escapeSQL).join(",")}) VALUES (${firstRow.map((e) => '?').join(",")})";
    if (LiteSQL._supportReturning && returning != null) {
      sql += returning.clause;
    }
    PreparedStatement st = prepareSQL(sql);
    List<int> idList = [];
    for (var oneRow in rows) {
      var argList = oneRow.mapList((e) => e.value);
      lastInsertRowId = 0;
      if (LiteSQL._supportReturning && returning != null) {
        ResultSet rs = st.select(argList);
        returning.returnRows.addAll(rs.allRows());
      } else {
        st.execute(argList);
      }
      idList.add(lastInsertRowId);
    }
    st.close();
    return idList;
  }

  ///   Returning rr = Returning(["*"]);
  ///   List< int > idList = lite.insertMulti("stu", ["name"], [['yang'], ['en'], ['tao']], returning: rr);
  ///
  ///   println("idList: ", idList); // [1, 2, 3]
  ///   println("returning: ", rr.returnRows); // [{id: 1, name: yang}, {id: 2, name: en}, {id: 3, name: tao}]
  List<int> insertMulti(String table, List<String> columns, List<List<dynamic>> rows, {InsertOption? conflict, Returning? returning}) {
    String cs = conflict == null ? "" : "OR ${conflict.conflict}";
    String sql = "INSERT $cs INTO ${table.escapeSQL} (${columns.map((e) => e.escapeSQL).join(",")}) VALUES (${columns.map((e) => '?').join(",")})";
    if (LiteSQL._supportReturning && returning != null) {
      sql += returning.clause;
    }
    PreparedStatement st = prepareSQL(sql);
    List<int> idList = [];
    for (var row in rows) {
      lastInsertRowId = 0;
      if (LiteSQL._supportReturning && returning != null) {
        ResultSet rs = st.select(row);
        returning.returnRows.addAll(rs.allRows());
      } else {
        st.execute(row);
      }
      idList.add(lastInsertRowId);
    }
    st.close();
    return idList;
  }

  int upsertFields(String table, List<ColumnValue> row, {Returning? returning}) {
    return upsert(
      table,
      values: row.mapList((e) => e.column.columnName >> e.value),
      constraints: row.filter((e) => e.column.proto.primaryKey || e.column.proto.unique).mapList((e) => e.column.columnName),
      returning: returning,
    );
    // return upsertRows(table, [row]).firstOrNull ?? 0;
  }

  /// constraints can empty.
  int upsertBy(String table, {required List<(String, dynamic)> values, required List<String> constraints, InsertOption? conflict, Returning? returning}) {
    return upsert(table, values: values.mapList((e) => LabelValue(e.$1, e.$2)), constraints: constraints, conflict: conflict, returning: returning);
  }

  ///   Returning ur = Returning.ALL;
  ///   int id = lite.upsertOne("stu", values: ["id" >> 1, "name" >> "entao"], constraints: ["id"], returning: ur);
  ///   println("id: ", id); // 0
  ///   println("returning: ", ur.returnRows); //  [{id: 1, name: entao}]
  ///
  ///   constraints can empty.
  int upsert(String table, {required List<LabelValue<dynamic>> values, required List<String> constraints, InsertOption? conflict, Returning? returning}) {
    assert(values.isNotEmpty);
    List<LabelValue<dynamic>> otherValues = constraints.isEmpty ? [] : values.filter((e) => !constraints.contains(e.label));

    String sql = "INSERT INTO ${table.escapeSQL} (${values.map((e) => e.label.escapeSQL).join(", ")}) VALUES ( ${values.map((e) => '?').join(", ")} )";
    if (constraints.isNotEmpty) {
      if (otherValues.isEmpty) {
        sql += " ON CONFLICT (${constraints.mapList((e) => e.escapeSQL).join(", ")}) DO NOTHING";
      } else {
        sql += " ON CONFLICT (${constraints.mapList((e) => e.escapeSQL).join(", ")}) DO UPDATE SET ${otherValues.map((e) => "${e.label.escapeSQL} = ?").join(", ")}";
      }
    }
    var argList = [...values.mapList((e) => e.value), ...otherValues.mapList((e) => e.value)];
    lastInsertRowId = 0;
    if (LiteSQL._supportReturning && returning != null) {
      sql += returning.clause;
      ResultSet rs = rawQuery(sql, argList);
      returning.returnRows.addAll(rs.allRows());
    } else {
      execute(sql, argList);
    }
    return lastInsertRowId;
  }

  List<int> upsertRows(String table, List<List<ColumnValue>> rows, {Returning? returning}) {
    assert(rows.isNotEmpty);
    var firstRow = rows.first;
    return upsertMulti(
      table,
      columns: firstRow.mapList((e) => e.column.columnName),
      values: rows.mapList((e) => e.mapList((x) => x.value)),
      constraints: firstRow.filter((e) => e.column.proto.primaryKey || e.column.proto.unique).mapList((e) => e.column.columnName),
      returning: returning,
    );
  }

  List<int> upsertMulti(
    String table, {
    required List<String> columns,
    required List<List<dynamic>> values,
    required List<String> constraints,
    InsertOption? conflict,
    Returning? returning,
  }) {
    assert(values.isNotEmpty);
    List<String> otherCols = columns.filter((e) => !constraints.contains(e));

    String sql = "INSERT INTO ${table.escapeSQL} (${columns.map((e) => e.escapeSQL).join(", ")}) VALUES ( ${columns.map((e) => '?').join(", ")} )";
    if (constraints.isNotEmpty) {
      if (otherCols.isEmpty) {
        sql += " ON CONFLICT (${constraints.map((e) => e.escapeSQL).join(", ")}) DO NOTHING";
      } else {
        sql += " ON CONFLICT (${constraints.map((e) => e.escapeSQL).join(", ")}) DO UPDATE SET ${otherCols.map((e) => "${e.escapeSQL} = ?").join(", ")}";
      }
    }
    bool useReturn = LiteSQL._supportReturning && returning != null;
    if (useReturn) {
      sql += returning.clause;
    }
    PreparedStatement ps = prepareSQL(sql);
    List<int> idList = [];
    for (List<dynamic> oneRow in values) {
      var argList = [...oneRow, ...otherCols.mapList((e) => oneRow[columns.indexOf(e)])];
      lastInsertRowId = 0;
      if (useReturn) {
        sql += returning.clause;
        ResultSet rs = ps.select(argList);
        returning.returnRows.addAll(rs.allRows());
      } else {
        ps.execute(argList);
      }
      idList << lastInsertRowId;
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
