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
  ///   List<int> idList = lite.insertRows("stu", [
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
  ///   List<int> idList = lite.insertMulti("stu", ["name"], [['yang'], ['en'], ['tao']], returning: rr);
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

  int upsert(String table, List<FieldValue> row) {
    return upsertRows(table, [row]).firstOrNull ?? 0;
  }

  List<int> upsertRows(String table, List<List<FieldValue>> rows) {
    if (rows.isEmpty) return [];
    List<FieldValue> firstRow = rows.first;
    List<FieldValue> uniqueList = firstRow.filter((e) => e.field.primaryKey || e.field.unique);
    List<FieldValue> otherList = firstRow.filter((e) => !e.field.primaryKey && !e.field.unique);

    String sql = "INSERT INTO ${table.escapeSQL} (${firstRow.map((e) => e.field.nameSQL).join(", ")}) VALUES ( ${firstRow.map((e) => '?').join(", ")} )";
    if (uniqueList.isNotEmpty) {
      List<String> conflicts = uniqueList.mapList((e) => e.field.nameSQL);
      if (otherList.isEmpty) {
        sql += " ON CONFLICT (${conflicts.join(", ")}) DO NOTHING";
      } else {
        sql += " ON CONFLICT (${conflicts.join(", ")}) DO UPDATE SET ${otherList.map((e) => "${e.field.nameSQL} = ?").join(", ")}";
      }
    }
    List<int> rowids = [];
    PreparedStatement st = prepareSQL(sql);
    for (var row in rows) {
      List<FieldValue> uniqueList = row.filter((e) => e.field.primaryKey || e.field.unique);
      List<FieldValue> otherList = row.filter((e) => !e.field.primaryKey && !e.field.unique);
      List<dynamic> argList = row.mapList((e) => e.value);
      if (uniqueList.isNotEmpty && otherList.isNotEmpty) {
        argList.addAll(otherList.map((e) => e.value));
      }
      logSQL.d(argList);
      lastInsertRowId = 0;
      st.execute(argList);
      rowids.add(lastInsertRowId);
    }
    st.close();
    return rowids;
  }
}
