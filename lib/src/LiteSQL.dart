part of 'sql.dart';

class LiteSQL {
  final Database database;
  final ffi.Pointer<ffi.Opaque> _nativeDatabase;
  late final Pragma PRAGMA = Pragma(this);

  LiteSQL({required this.database}) : _nativeDatabase = ffi.Pointer<ffi.Opaque>.fromAddress(database.handle.address);

  static Version version = sqlite3.version;

  // ignore: unused_field
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

  QueryResult execute(String sql, [List<Object?>? parameters]) {
    logSQL.d(sql);
    if (parameters != null && parameters.isNotEmpty) {
      logSQL.d(parameters);
    }
    return database.select(sql, parameters ?? const []).queryResult;
  }

  StepCursor stepQuery(String sql, [List<Object?>? parameters]) {
    logSQL.d(sql);
    if (parameters != null && parameters.isNotEmpty) {
      logSQL.d(parameters);
    }
    PreparedStatement ps = database.prepare(sql);
    IteratingCursor cursor = ps.selectCursor(parameters ?? const []);
    return StepCursor(cursor: cursor, statement: ps);
  }

  List<QueryResult> multiQuery(String sql, Iterable<AnyList> allParameters) {
    assert(allParameters.isNotEmpty);
    List<QueryResult> rs = [];
    PreparedStatement ps = prepareSQL(sql);
    for (AnyList ls in allParameters) {
      rs << ps.select(ls).queryResult;
    }
    ps.close();
    return rs;
  }

  PreparedStatement prepareSQL(String sql) {
    logSQL.d(sql);
    return database.prepare(sql);
  }

  R transaction<R>(R Function() callback) {
    execute("BEGIN");
    try {
      R r = callback();
      execute("COMMIT");
      return r;
    } catch (e) {
      execute("ROLLBACK");
      rethrow;
    }
  }

  /// liteSQL.register(Person.values)
  void register<T extends TableColumn>(List<T> fields, {String? tableName, void Function(TableProto)? migrator, bool useBasicMigrator = true}) {
    TableProto.register(this, fields, tableName: tableName, migrator: migrator, useBasicMigrator: useBasicMigrator);
  }

  List<SqliteTableInfo> tableInfo(String tableName) {
    String sql = "PRAGMA table_info(${tableName.escapeSQL})";
    QueryResult rs = execute(sql);
    return rs.listModels(SqliteTableInfo.new);
  }

  List<String> _indexInfo(String indexName) {
    String sql = "PRAGMA index_info(${indexName.escapeSQL})";
    QueryResult rs = execute(sql);
    return rs.listValues("name");
  }

  List<IndexName> listIndex() {
    String sql = "SELECT tbl_name, name FROM sqlite_master WHERE type='index'";
    QueryResult rs = execute(sql);
    return rs.mapList((r) => IndexName(table: r[0] as String, index: r[1] as String));
  }

  List<String> _listTable() {
    String sql = "SELECT name FROM sqlite_master WHERE type = 'table'";
    QueryResult rs = execute(sql);
    return rs.listValues();
  }

  bool existTable(String table) {
    String sql = "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?";
    QueryResult rs = execute(sql, [table]);
    return rs.isNotEmpty;
  }

  int countTable(String table) {
    String sql = "SELECT count(*) FROM ${table.escapeSQL}";
    QueryResult rs = execute(sql);
    return rs.firstValue() ?? 0;
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

class IndexName {
  String table;
  String index;

  IndexName({required this.table, required this.index});

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
