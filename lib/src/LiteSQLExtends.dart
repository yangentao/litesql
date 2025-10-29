part of 'sql.dart';

extension LiteSQLEnum on LiteSQL {
  // <T extends ETable<T>>
  void dumpTableE(Type type) {
    TableSQL? t = findTableByType(type);
    if (t == null) {
      println("NO table found: $type");
      return;
    }
    this.dumpTable(t.nameSQL);
  }

  ResultSet queryE(
    Object from, {
    List<dynamic>? columns,
    Where? where,
    List<Where>? wheres,
    String? groupBy,
    String? having,
    String? window,
    String? order,
    List<String>? orderBy,
    int? limit,
    int? offset,
  }) {
    List<Where> wList = [where, ...?wheres].nonNullList;
    var w = AND_ALL(wList).result();
    return this.select(
      columns?.mapList((e) => e is ETable ? e.nameSQL : e.toString()),
      from: switch (from) {
        ETable _ => from.tableName,
        Type _ => "$from",
        _ => from.toString(),
      },
      where: w.clause,
      groupBy: groupBy,
      having: having,
      window: window,
      order: order,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
      args: w.args,
    );
  }
}
