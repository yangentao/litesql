part of 'sql.dart';

class TableProto<E extends TableColumn> {
  final String name;
  final List<TableColumn<E>> columns;
  final String nameSQL;
  final LiteSQL liteSQL;
  late final List<TableColumn<E>> primaryKeys = columns.filter((e) => e.proto.primaryKey);

  TableProto._(this.name, this.columns, {required this.liteSQL}) : nameSQL = name.escapeSQL {
    for (var e in columns) {
      e.tableProto = this;
    }
    _enumTypeMap[E] = this;
  }

  factory TableProto() {
    TableProto? p = _enumTypeMap[E];
    if (p == null) {
      errorSQL("NO table proto of '$E' found, migrate it first. for example: liteSQL.migrate(Person.values) ");
    }
    return p as TableProto<E>;
  }

  TableColumn? find(String fieldName) {
    return columns.firstWhere((e) => e.columnName == fieldName);
  }

  // after migrate
  static TableProto of(Type type) {
    TableProto? p = _enumTypeMap[type];
    if (p == null) {
      errorSQL("NO table proto of $type  found, migrate it first. ");
    }
    return p;
  }

  static bool isMigrated<T>() => _enumTypeMap.containsKey(T);

  static final Map<Type, TableProto> _enumTypeMap = {};
}

TableProto $(Type type) => TableProto.of(type);

TableProto PROTO(Type type) => TableProto.of(type);

void _migrateEnumTable<T extends TableColumn<T>>(LiteSQL lite, List<T> fields) {
  assert(fields.isNotEmpty);
  if (TableProto.isMigrated<T>()) return;
  TableProto<T> tab = TableProto<T>._(fields.first.tableName, fields, liteSQL: lite);
  _migrateTable(lite, tab.name, tab.columns);
}

void _migrateTable(LiteSQL lite, String tableName, List<TableColumn> fields) {
  if (!lite.existTable(tableName)) {
    lite.createTable(tableName, fields);
    return;
  }

  List<SqliteTableInfo> cols = lite.tableInfo(tableName);
  Set<String> colSet = cols.map((e) => e.name).toSet();
  for (TableColumn f in fields) {
    if (!colSet.contains(f.columnName)) {
      lite.addColumn(tableName, f);
    }
  }
  Set<String> idxSet = {};
  for (var a in lite._listIndex()) {
    var ls = lite._indexInfo(a.index);
    if (ls.length == 1) {
      idxSet.add(ls.first);
    }
  }
  for (TableColumn f in fields) {
    if (f.proto.primaryKey || f.proto.unique || notBlank(f.proto.uniqueName)) continue;
    if (f.proto.index && !idxSet.contains(f.columnName)) {
      lite.createIndex(tableName, [f.columnName]);
    }
  }
}
