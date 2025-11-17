part of 'sql.dart';

extension LiteUpdateExt on LiteSQL {
  /// Returning ret = Returning.ALL;
  /// int n = lite.delete("stu", where: "id=1", returning: ret);
  /// println("del count: ", n); // 1
  /// println(ret.returnRows); // [{id: 1, name: yang}]
  int delete(String table, {required String where, ArgSQL? args, Returning? returning}) {
    assert(where.isNotEmpty);
    String sql = "DELETE FROM ${table.escapeSQL} WHERE $where";
    if (LiteSQL.supportReturning && returning != null) {
      sql += " ${returning.clause}";
      ResultSet rs = rawQuery(sql, args);
      returning.returnRows.addAll(rs.listRows);
    } else {
      execute(sql, args);
    }
    return updatedRows;
  }

  ///  Returning ret = Returning(["name"]);
  ///  int n  = lite.update("stu", ["name" >> "yangentao"], where: "id=1", returning: ret);
  ///  println("update count: ", n ); // 1
  ///  println(ret.returnRows); // [{name: yangentao}]
  int update(String table, List<LabelValue<dynamic>> values, {String? where, ArgSQL? args, Returning? returning}) {
    return updateBy(table, values.mapList((e) => (e.label, e.value)), where: where, args: args, returning: returning);
  }

  /// int n = update("person", [("name", "entao"), ("addr", "Peiking")]);
  int updateBy(String table, List<(String, dynamic)> values, {String? where, ArgSQL? args, Returning? returning}) {
    assert(values.isNotEmpty);
    var argList = <dynamic>[...values.mapList((e) => e.$2), ...?args];

    String sql = "UPDATE ${table.escapeSQL} SET ${values.map((e) => "${e.$1.escapeSQL} = ?").join(", ")}";
    if (notBlank(where)) {
      sql += " WHERE $where";
    }
    if (LiteSQL.supportReturning && returning != null) {
      sql += " ${returning.clause}";
      ResultSet rs = rawQuery(sql, argList);
      returning.returnRows.addAll(rs.listRows);
    } else {
      execute(sql, argList);
    }
    return updatedRows;
  }
}
