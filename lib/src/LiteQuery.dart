part of 'sql.dart';

extension LiteQueryExt on LiteSQL {
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
}
