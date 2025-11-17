part of 'sql.dart';

extension LiteSqlInsertExt on LiteSQL {
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
    if (LiteSQL.supportReturning && returning != null) {
      sql += " ${returning.clause}";
      ResultSet rs = rawQuery(sql, args);
      returning.returnRows.addAll(rs.listRows);
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
    if (LiteSQL.supportReturning && returning != null) {
      sql += " ${returning.clause}";
    }
    PreparedStatement st = prepareSQL(sql);
    List<int> idList = [];
    for (var oneRow in rows) {
      var argList = oneRow.mapList((e) => e.value);
      lastInsertRowId = 0;
      if (LiteSQL.supportReturning && returning != null) {
        ResultSet rs = st.select(argList);
        returning.returnRows.addAll(rs.listRows);
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
    if (LiteSQL.supportReturning && returning != null) {
      sql += " ${returning.clause}";
    }
    PreparedStatement st = prepareSQL(sql);
    List<int> idList = [];
    for (var row in rows) {
      lastInsertRowId = 0;
      if (LiteSQL.supportReturning && returning != null) {
        ResultSet rs = st.select(row);
        returning.returnRows.addAll(rs.listRows);
      } else {
        st.execute(row);
      }
      idList.add(lastInsertRowId);
    }
    st.close();
    return idList;
  }

  int upsertFields(String table, List<FieldValue> row, {Returning? returning}) {
    return upsert(
      table,
      values: row.mapList((e) => e.field.name >> e.value),
      constraints: row.filter((e) => e.field.primaryKey || e.field.unique).mapList((e) => e.field.name),
      returning: returning,
    );
    // return upsertRows(table, [row]).firstOrNull ?? 0;
  }

  List<int> upsertRows(String table, List<List<FieldValue>> rows, {Returning? returning}) {
    assert(rows.isNotEmpty);
    var firstRow = rows.first;
    return upsertMulti(
      table,
      columns: firstRow.mapList((e) => e.field.name),
      values: rows.mapList((e) => e.mapList((x) => x.value)),
      constraints: firstRow.filter((e) => e.field.primaryKey || e.field.unique).mapList((e) => e.field.name),
      returning: returning,
    );
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
    if (LiteSQL.supportReturning && returning != null) {
      sql += returning.clause;
      ResultSet rs = rawQuery(sql, argList);
      returning.returnRows.addAll(rs.listRows);
    } else {
      execute(sql, argList);
    }
    return lastInsertRowId;
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
    bool useReturn = LiteSQL.supportReturning && returning != null;
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
        returning.returnRows.addAll(rs.listRows);
      } else {
        ps.execute(argList);
      }
      idList << lastInsertRowId;
    }
    ps.close();
    return idList;
  }
}
