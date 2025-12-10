part of '../sql.dart';

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
    _createTable(lite, tableName, fields);
    return;
  }

  List<SqliteTableInfo> cols = lite.tableInfo(tableName);
  Set<String> colSet = cols.map((e) => e.name).toSet();
  for (TableColumn f in fields) {
    if (!colSet.contains(f.columnName)) {
      _addColumn(lite, tableName, f);
    }
  }
  Set<String> idxSet = {};
  List<LiteIndexItem> idxList = lite.PRAGMA.index_list(tableName);
  for (LiteIndexItem a in idxList) {
    List<LiteIndexInfo> ls = lite.PRAGMA.index_info(a.name);
    idxSet.addAll(ls.map((e) => e.name));
  }
  for (TableColumn f in fields) {
    if (f.proto.primaryKey || f.proto.unique || notBlank(f.proto.uniqueName)) continue;
    if (f.proto.index && !idxSet.contains(f.columnName)) {
      lite.createIndex(tableName, [f.columnName]);
    }
  }
}

void _addColumn(LiteSQL lite, String table, TableColumn field) {
  String sql = "ALTER TABLE ${table.escapeSQL} ADD COLUMN ${field.defineField(false)}";
  lite.execute(sql);
}

void _createTable(LiteSQL lite, String table, List<TableColumn> fields, {List<String>? constraints, List<String>? options, bool notExist = true}) {
  List<String> ls = [];
  if (notExist) {
    ls << "CREATE TABLE IF NOT EXISTS ${table.escapeSQL} (";
  } else {
    ls << "CREATE TABLE ${table.escapeSQL} (";
  }

  List<String> colList = [];

  List<TableColumn> keyFields = fields.filter((e) => e.proto.primaryKey);
  colList.addAll(fields.map((e) => e.defineField(keyFields.length > 1)));

  if (keyFields.length > 1) {
    colList << "PRIMARY KEY ( ${keyFields.map((e) => e.nameSQL).join(", ")})";
  }
  List<TableColumn> uniqeList = fields.filter((e) => e.proto.uniqueName != null && e.proto.uniqueName!.isNotEmpty);
  if (uniqeList.isNotEmpty) {
    Map<String, List<TableColumn>> map = uniqeList.groupBy((e) => e.proto.uniqueName!);
    for (var e in map.entries) {
      colList << "UNIQUE (${e.value.map((f) => f.nameSQL).join(", ")})";
    }
  }

  if (constraints != null && constraints.isNotEmpty) {
    colList.addAll(constraints);
  }
  ls << colList.join(",\n");
  if (options != null && options.isNotEmpty) {
    ls << ") ${options.join(",")}";
  } else {
    ls << ")";
  }

  String sql = ls.join("\n");
  lite.execute(sql);

  for (var f in fields) {
    if (f.proto.primaryKey || f.proto.unique || notBlank(f.proto.uniqueName)) {
      continue;
    }
    if (f.proto.index) {
      lite.createIndex(table, [f.columnName]);
    }
  }
}
