part of 'sql.dart';

class EnumTable {
  LiteSQL lite;
  Type tableType;
  late TableSQL tableSQL;

  EnumTable({required this.lite, required this.tableType}) {
    var t = findTableByType(tableType);
    if (t == null) {
      throw SQLException("Table info NOT found, type=$tableType");
    }
    tableSQL = t;
  }

  String get tableName => tableSQL.nameSQL;

  void dump() {
    lite.dumpTable(tableName);
  }

  // <T extends ETable<T>>

  ResultSet query(
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
    return lite.select(
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

extension LiteSQLEnum on LiteSQL {
  EnumTable from(Type table) {
    return EnumTable(lite: this, tableType: table);
  }
}
