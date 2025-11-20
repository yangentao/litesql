part of 'sql.dart';

class LiteSQL {
  final Database database;
  final ffi.Pointer<ffi.Opaque> _nativeDatabase;

  LiteSQL({required this.database}) : _nativeDatabase = ffi.Pointer<ffi.Opaque>.fromAddress(database.handle.address);

  static Version version = sqlite3.version;
  static final bool _supportReturning = version.versionNumber >= 3035000;

  static LiteSQL open(String path, {String? vfs, OpenMode mode = OpenMode.readWriteCreate, bool uri = false, bool? mutex}) {
    var db = sqlite3.open(path, vfs: vfs, mode: mode, uri: uri, mutex: mutex);
    return LiteSQL(database: db);
  }

  static LiteSQL openMemory() => LiteSQL(database: sqlite3.openInMemory());

  // @Deprecated("use EnumTable instead.")
  // SingleTable table(TableProto t) => SingleTable(lite: this, table: t);

  void close() {
    database.close();
  }

  int get user_version => database.userVersion;

  set user_version(int version) => database.userVersion = version;

  int get updatedRows => database.updatedRows;

  int get lastInsertRowId => database.lastInsertRowId;

  set lastInsertRowId(int value) => xsql.sqlite3_set_last_insert_rowid(_nativeDatabase, value);

  void dumpTable(String table) {
    rawQuery("SELECT * FROM ${table.escapeSQL}").dump();
  }

  void execute(String sql, [List<Object?>? parameters]) {
    logSQL.d(sql);
    if (parameters != null && parameters.isNotEmpty) {
      logSQL.d(parameters);
    }
    database.execute(sql, parameters ?? const []);
  }

  int rawUpdate(String sql, [List<Object?>? parameters]) {
    execute(sql, parameters);
    return updatedRows;
  }

  int rawInsert(String sql, [List<Object?>? parameters]) {
    lastInsertRowId = 0;
    execute(sql, parameters);
    return lastInsertRowId;
  }

  ResultSet rawQuery(String sql, [List<Object?>? parameters]) {
    logSQL.d(sql);
    if (parameters != null && parameters.isNotEmpty) {
      logSQL.d(parameters);
    }
    return database.select(sql, parameters ?? const []);
  }

  PreparedStatement prepareSQL(String sql) {
    logSQL.d(sql);
    return database.prepare(sql);
  }

  void transaction(void Function() callback) {
    execute("BEGIN");
    try {
      callback();
      execute("COMMIT");
    } catch (e) {
      execute("ROLLBACK");
      rethrow;
    }
  }

  /// liteSQL.migrate(Person.values)
  void migrate<T extends TableColumn<T>>(List<T> fields) {
    _migrateEnumTable(this, fields);
  }

  List<SqliteTableInfo> tableInfo(String tableName) {
    String sql = "PRAGMA table_info(${tableName.escapeSQL})";
    ResultSet rs = database.select(sql);
    return rs.listModels(SqliteTableInfo.new);
  }

  List<String> _indexInfo(String indexName) {
    String sql = "PRAGMA index_info(${indexName.escapeSQL})";
    ResultSet rs = rawQuery(sql);
    return rs.mapList((e) => e['name']);
  }

  List<_IndexName> _listIndex() {
    String sql = "SELECT tbl_name, name FROM sqlite_master WHERE type='index'";
    ResultSet rs = rawQuery(sql);
    return rs.mapList((r) => _IndexName(table: r.columnAt(0), index: r.columnAt(1)));
  }

  List<String> _listTable() {
    String sql = "SELECT name FROM sqlite_master WHERE type = 'table'";
    ResultSet rs = rawQuery(sql);
    return rs.mapList((r) => r.columnAt(0));
  }

  bool existTable(String table) {
    String sql = "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?";
    ResultSet rs = rawQuery(sql, [table]);
    return rs.isNotEmpty;
  }

  int countTable(String table) {
    String sql = "SELECT count(*) FROM ${table.escapeSQL}";
    ResultSet rs = rawQuery(sql);
    return rs.firstOrNull?.columnAt(0) ?? 0;
  }

  void dropTable(String table) {
    String sql = "DROP TABLE IF EXISTS ${table.escapeSQL}";
    execute(sql);
  }

  void dropIndex(String table, String fieldName) {
    String idx = _makeIndexName(table, [fieldName]);
    String sql = "DROP INDEX IF EXISTS $idx";
    execute(sql);
  }

  void addColumn(String table, TableColumn field) {
    String sql = "ALTER TABLE ${table.escapeSQL} ADD COLUMN ${field.defineField(false)}";
    execute(sql);
  }

  void createIndex(String table, List<String> fields) {
    String idxName = _makeIndexName(table, fields);
    String sql = "CREATE INDEX IF NOT EXISTS $idxName ON ${table.escapeSQL} (${fields.map((e) => e.escapeSQL).join(",")})";
    execute(sql);
  }

  void createTable(String table, List<TableColumn> fields, {List<String>? constraints, List<String>? options, bool notExist = true}) {
    ListString ls = [];
    if (notExist) {
      ls << "CREATE TABLE IF NOT EXISTS ${table.escapeSQL} (";
    } else {
      ls << "CREATE TABLE ${table.escapeSQL} (";
    }

    ListString colList = [];

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
    execute(sql);

    for (var f in fields) {
      if (f.proto.primaryKey || f.proto.unique || notBlank(f.proto.uniqueName)) {
        continue;
      }
      if (f.proto.index) {
        createIndex(table, [f.columnName]);
      }
    }
  }
}

String _makeIndexName(String table, List<String> fields) {
  var ls = fields.sorted(null);
  return "${table}_${ls.join("_")}";
}

class _IndexName {
  String table;
  String index;

  _IndexName({required this.table, required this.index});

  @override
  String toString() {
    return "IndexName(table: $table, index: $index)";
  }
}

class SqliteTableInfo extends MapModel {
  SqliteTableInfo(super.model);

  int get cid => get("cid");

  String get name => get("name");

  String get type => get("type");

  bool get notnull => get<int>("notnull") == 1;

  String? get dflt_value => get("dflt_value");

  bool get pk => get<int>("pk") == 1;
}

class TableProto<E extends TableColumn<E>> {
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

TableProto TABLE(Type type) => TableProto.of(type);

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
