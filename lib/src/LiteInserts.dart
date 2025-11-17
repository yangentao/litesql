part of 'sql.dart';

extension LiteSqlInsertExt on LiteSQL {
  List<int> insertRowsReturning(String table, List<List<LabelValue<dynamic>>> rows, {InsertOption? conflict, Returning? returning}) {
    if (rows.isEmpty) return List.empty();
    var firstRow = rows.first;
    String cs = conflict == null ? "" : "OR ${conflict.conflict}";
    String sql = "INSERT $cs INTO ${table.escapeSQL} (${firstRow.map((e) => e.label.escapeSQL).join(",")}) VALUES (${firstRow.map((e) => '?').join(",")})";
    if (returning != null && returning.columns.isNotEmpty) {
      sql = "$sql RETURNING ${returning.columns.join(", ")}";
    }
    PreparedStatement st = prepareSQL(sql);
    List<int> idList = [];
    for (var oneRow in rows) {
      lastInsertRowId = 0;
      if (returning != null) {
        ResultSet rs = st.select(oneRow.mapList((e) => e.value));
        returning.values.add(rs.firstRow ?? {});
      } else {
        st.execute(oneRow.mapList((e) => e.value));
      }
      idList.add(lastInsertRowId);
    }
    st.close();
    return idList;
  }

  List<int> insertRows(String table, List<List<LabelValue<dynamic>>> rows, {InsertOption? conflict}) {
    if (rows.isEmpty) return List.empty();
    var firstRow = rows.first;
    String cs = conflict == null ? "" : "OR ${conflict.conflict}";
    String sql = "INSERT $cs INTO ${table.escapeSQL} (${firstRow.map((e) => e.label.escapeSQL).join(",")}) VALUES (${firstRow.map((e) => '?').join(",")})";
    PreparedStatement st = prepareSQL(sql);
    List<int> idList = [];
    for (var oneRow in rows) {
      lastInsertRowId = 0;
      st.execute(oneRow.mapList((e) => e.value));
      idList.add(lastInsertRowId);
    }
    st.close();
    return idList;
  }

  List<int> insertMulti(String table, List<String> columns, List<List<dynamic>> rows, {InsertOption? conflict}) {
    String cs = conflict == null ? "" : "OR ${conflict.conflict}";
    String sql = "INSERT $cs INTO ${table.escapeSQL} (${columns.map((e) => e.escapeSQL).join(",")}) VALUES (${columns.map((e) => '?').join(",")})";
    PreparedStatement st = prepareSQL(sql);
    List<int> idList = [];
    for (var row in rows) {
      lastInsertRowId = 0;
      st.execute(row);
      idList.add(lastInsertRowId);
    }
    st.close();
    return idList;
  }

  int insertPairs(String table, List<LabelValue<dynamic>> pairs, {InsertOption? conflict}) {
    return insertRows(table, [pairs], conflict: conflict).first;
  }

  int insert(String table, List<String> columns, List<dynamic> values, {InsertOption? conflict}) {
    return insertMulti(table, columns, [values], conflict: conflict).first;
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
