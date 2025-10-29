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

  void dump() {
    lite.dumpTable(tableName);
  }
}

extension LiteSQLEnum on LiteSQL {
  /// liteSQL.migrateEnumTable(Person.values)
  void migrateEnumTable<T extends ETable<T>>(List<T> fields) {
    MigrateETable(this, fields);
  }

  /// liteSQL.from(Person)
  EnumTable from(Type table) {
    return EnumTable(lite: this, tableType: table);
  }
}

extension ETableFieldValueEx<T> on ETable<T> {
  FieldValue operator >>(dynamic value) {
    TableSQL? t = findTableByType(this.runtimeType);
    assert(t != null);
    return FieldValue(t!.fields.firstWhere((e) => e.name == this.nameColumn), value);
  }
}
