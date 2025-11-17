part of 'sql.dart';

class LiteSQL {
  Database database;
  late final ffi.Pointer<ffi.Opaque> _nativeDatabase = ffi.Pointer<ffi.Opaque>.fromAddress(database.handle.address);

  LiteSQL({required this.database});

  static Version version = sqlite3.version;
  static final bool _supportReturning = version.versionNumber >= 3035000;

  static LiteSQL open(String path) {
    var db = sqlite3.open(path);
    return LiteSQL(database: db);
  }

  static LiteSQL openMemory() {
    var db = sqlite3.openInMemory();
    return LiteSQL(database: db);
  }

  static String _makeIndexName(String table, List<String> fields) {
    var ls = fields.sorted(null);
    return "${table}_${ls.join("_")}";
  }

  // @Deprecated("use EnumTable instead.")
  // SingleTable table(TableProto t) => SingleTable(lite: this, table: t);

  void close() {
    database.close();
  }

  int get user_version => database.userVersion;

  set user_version(int ver) => database.userVersion = ver;

  int get updatedRows => database.updatedRows;

  int get lastInsertRowId => database.lastInsertRowId;

  set lastInsertRowId(int value) => xsql.sqlite3_set_last_insert_rowid(_nativeDatabase, value);

  void dumpTable(String table) {
    String sql = "SELECT * FROM ${table.escapeSQL}";
    ResultSet rs = rawQuery(sql);
    for (Row r in rs) {
      logSQL.d(r.mapSQL);
    }
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

  void migrate(TableProto table) {
    MigrateTable(this, table.name, table.fields);
  }

  void migrateTable(String tableName, List<FieldProto> fields) {
    MigrateTable(this, tableName, fields);
  }

  List<TableInfoItem> tableInfo(String tableName) {
    String sql = "PRAGMA table_info(${tableName.escapeSQL})";
    ResultSet rs = database.select(sql);
    return rs.mapList((e) {
      var item = TableInfoItem();
      item.cid = e['cid'] ?? 0;
      item.name = e['name'] ?? "";
      item.type = e['type'] ?? "";
      item.notNull = e['notnull'] != 0;
      item.pk = e['pk'] != 0;
      return item;
    });
  }

  List<String> indexInfo(String indexName) {
    String sql = "PRAGMA index_info(${indexName.escapeSQL})";
    ResultSet rs = rawQuery(sql);
    return rs.mapList((e) => e['name']);
  }

  List<IndexName> listIndex() {
    String sql = "SELECT  tbl_name , name FROM sqlite_master WHERE type='index'";
    ResultSet rs = rawQuery(sql);
    return rs.mapList((r) => IndexName(table: r.columnAt(0), index: r.columnAt(1)));
  }

  List<String> listTable() {
    String sql = "SELECT name FROM sqlite_master WHERE type = 'table'";
    ResultSet rs = rawQuery(sql);
    return rs.mapList((r) => r.columnAt(0));
  }

  bool existTable(String table) {
    String sql = "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ${table.singleQuoted}";
    ResultSet rs = rawQuery(sql);
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

  void addColumn(String table, FieldProto field) {
    String sql = "ALTER TABLE ${table.escapeSQL} ADD COLUMN ${field.defineField(false)}";
    execute(sql);
  }

  void createIndex(String table, List<String> fields) {
    String idxName = _makeIndexName(table, fields);
    String sql = "CREATE INDEX IF NOT EXISTS $idxName ON ${table.escapeSQL} (${fields.map((e) => e.escapeSQL).join(",")})";
    execute(sql);
  }

  void createTable(String table, List<FieldProto> fields, {List<String>? constraints, List<String>? options, bool notExist = true}) {
    ListString ls = [];
    if (notExist) {
      ls << "CREATE TABLE IF NOT EXISTS ${table.escapeSQL} (";
    } else {
      ls << "CREATE TABLE ${table.escapeSQL} (";
    }

    ListString colList = [];

    List<FieldProto> keyFields = fields.filter((e) => e.primaryKey);
    colList.addAll(fields.map((e) => e.defineField(keyFields.length > 1)));

    if (keyFields.length > 1) {
      colList << "PRIMARY KEY ( ${keyFields.map((e) => e.nameSQL).join(", ")})";
    }
    List<FieldProto> uniqeList = fields.filter((e) => e.uniqueName != null && e.uniqueName!.isNotEmpty);
    if (uniqeList.isNotEmpty) {
      Map<String, List<FieldProto>> map = uniqeList.groupBy((e) => e.uniqueName!);
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
      if (f.primaryKey || f.unique || notBlank(f.uniqueName)) {
        continue;
      }
      if (f.index) {
        createIndex(table, [f.name]);
      }
    }
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

//"cid": 0,
//"name": "locale",
//"type": "TEXT",
//"notnull": 0,
//"dflt_value": null,
//"pk": 0
class TableInfoItem {
  int cid = 0;
  String name = "";
  String type = "";
  bool notNull = false;
  String? defaultValue;
  bool pk = false;

  @override
  String toString() {
    return "TableInfo(cid:$cid, name:$name, type:$type, pk:$pk,  notnull:$notNull, defaultValue:$defaultValue)";
  }
}
