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

  ResultSet selectE(
    List<dynamic>? columns, {
    required Object from,
    String? where,
    String? groupBy,
    String? having,
    String? window,
    String? order,
    List<String>? orderBy,
    int? limit,
    int? offset,
    List<dynamic>? args,
  }) {
    return this.select(
      columns?.mapList((e) => e is ETable ? e.nameSQL : e.toString()),
      from: switch (from) {
        ETable _ => from.tableName,
        Type _ => "$from",
        _ => from.toString(),
      },
      where: where,
      groupBy: groupBy,
      having: having,
      window: window,
      order: order,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
      args: args,
    );
  }
}
