part of 'sql.dart';

class LiteX {
  LiteSQL lite;

  LiteX(this.lite);

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
    return e.query(lite);
  }
}

extension LiteSQLX on LiteSQL {
  LiteX get X => LiteX(this);
}
