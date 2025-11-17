part of 'sql.dart';

extension LiteUpdateExt on LiteSQL {
  int delete(String table, {required String where, ArgSQL? args}) {
    assert(where.isNotEmpty);
    String sql = "DELETE FROM ${table.escapeSQL} WHERE $where";
    return rawUpdate(sql, args);
  }

  /// int n = update("person", ["name">>"entao", "addr">>"Peiking"]);
  int update(String table, List<LabelValue<dynamic>> values, {String? where, ArgSQL? args}) {
    assert(values.isNotEmpty);
    String sql = "UPDATE ${table.escapeSQL} SET ${values.map((e) => "${e.label.escapeSQL} = ?").join(", ")}";
    if (notBlank(where)) {
      sql += " WHERE $where";
    }
    var ls = <dynamic>[...values.mapList((e) => e.value), ...?args];
    return rawUpdate(sql, ls);
  }
}
