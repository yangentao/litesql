part of 'sql.dart';

void Migrate(LiteSQL lite, TableSQL table) {
  MigrateTable(lite, table.name, table.fields);
}

void MigrateTable(LiteSQL lite, String tableName, List<FieldSQL> fields) {
  if (!lite.existTable(tableName)) {
    lite.createTable(tableName, fields);
    return;
  }

  List<TableInfoItem> cols = lite.tableInfo(tableName);
  Set<String> colSet = cols.map((e) => e.name).toSet();
  for (FieldSQL f in fields) {
    if (!colSet.contains(f.name)) {
      lite.addColumn(tableName, f);
    }
  }
  Set<String> idxSet = {};
  for (var a in lite.listIndex()) {
    var ls = lite.indexInfo(a.index);
    if (ls.length == 1) {
      idxSet.add(ls.first);
    }
  }
  for (FieldSQL f in fields) {
    if (f.primaryKey || f.unique || notBlank(f.uniqueName)) continue;
    if (f.index && !idxSet.contains(f.name)) {
      lite.createIndex(tableName, [f.name]);
    }
  }
}
