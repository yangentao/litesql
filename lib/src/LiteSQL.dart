part of 'sql.dart';

class LiteSQL {
  final Database database;
  final ffi.Pointer<ffi.Opaque> _nativeDatabase;
  late final Pragma PRAGMA = Pragma(this);

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

  void vacuum() {
    execute("VACUUM");
  }

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

  void createIndex(String table, List<String> fields) {
    String idxName = _makeIndexName(table, fields);
    String sql = "CREATE INDEX IF NOT EXISTS $idxName ON ${table.escapeSQL} (${fields.map((e) => e.escapeSQL).join(",")})";
    execute(sql);
  }

  void createTable(String table, List<String> columns, {List<String> constraints = const [], List<String> options = const []}) {
    SpaceBuffer buf = SpaceBuffer();
    buf << "CREATE TABLE IF NOT EXISTS";
    buf << table;
    buf << "(";
    buf << columns.join(", ");
    if (constraints.isNotEmpty) {
      buf << ", ";
      buf << constraints.join(", ");
    }
    buf << ")";
    if (options.isNotEmpty) {
      buf << options.join(", ");
    }
    execute(buf.toString());
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
