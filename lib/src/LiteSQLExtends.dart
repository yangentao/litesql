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
}
