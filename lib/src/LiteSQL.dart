part of 'sql.dart';

class LiteSQL {
  Database db;

  LiteSQL({required this.db});

  SingleTable table(TableProto t) => SingleTable(lite: this, table: t);

  static LiteSQL open(String path) {
    var db = sqlite3.open(path);
    return LiteSQL(db: db);
  }

  static LiteSQL openMemory() {
    var db = sqlite3.openInMemory();
    return LiteSQL(db: db);
  }

  static String makeIndexName(String table, List<String> fields) {
    var ls = fields.sorted(null);
    return "${table}_${ls.join("_")}";
  }

  void dispose() {
    db.dispose();
  }

  void dumpTable(String table) {
    String sql = "SELECT * FROM ${table.escapeSQL}";
    ResultSet rs = db.select(sql);

    for (Row r in rs) {
      println(r.mapSQL);
    }
  }

  int get user_version => db.userVersion;

  set user_version(int ver) => db.userVersion = ver;

  /// distinct on
  /// SELECT a, b, max(c) FROM tab1 GROUP BY a;
  /// min/max 在聚合查询时,  会返回包含min/max值的行.
  /// 利用这特特性, 可以实现postgresql distinct on 的特性
  /// //https://sqlite.org/lang_select.html#bareagg
  /// https://sqlite.org/lang_select.html
  ResultSet select(
    List<String>? columns, {
    required String from,
    String? where,
    String? groupBy,
    String? having,
    String? window,
    String? order,
    List<String>? orderBy,
    int? limit,
    int? offset,
    List<dynamic>? args,
  }) {
    String sels = columns?.filter((e) => e.trim().isNotEmpty).map((e) => e.escapeSQL).join(", ") ?? "";
    if (sels.trim().isEmpty) {
      sels = "*";
    }
    String sql = "SELECT $sels FROM ${from.escapeSQL}";
    if (notBlank(where?.trim())) {
      sql += " WHERE $where";
    }
    if (notBlank(groupBy)) {
      sql += " GROUP BY $groupBy";
      if (notBlank(having)) {
        sql += " HAVING $having";
      }
    }
    if (notBlank(window)) {
      sql += " WINDOW $window";
    }
    List<String> os = [if (order != null) order, ...?orderBy].filter((e) => e.trim().isNotEmpty);
    if (os.isNotEmpty) {
      sql += " ORDER BY ${os.join(", ")}";
    }
    if (limit != null) {
      sql += " LIMIT $limit";
      if (offset != null) {
        sql += " OFFSET $offset";
      }
    }
    println(sql);
    ResultSet rs = db.select(sql, args ?? []);
    return rs;
  }

  PreparedStatement prepareSQL(String sql) {
    logd(sql);
    return db.prepare(sql);
  }

  int delete(String table, {required String where, ArgSQL? args}) {
    assert(where.isNotEmpty);
    String sql = "DELETE FROM ${table.escapeSQL} WHERE $where";
    PreparedStatement st = prepareSQL(sql);
    st.execute(args ?? []);
    st.dispose();
    return db.updatedRows;
  }

  int update(String table, List<LabelValue<dynamic>> values, {String? where, ArgSQL? args}) {
    String sql = "UPDATE ${table.escapeSQL} SET ${values.map((e) => "${e.label.escapeSQL} = ?").join(", ")}";
    if (notBlank(where)) {
      sql += " WHERE $where";
    }
    PreparedStatement st = prepareSQL(sql);
    st.execute(values.mapList((e) => e.value) + (args ?? []));
    st.dispose();
    return db.updatedRows;
  }

  List<int> upsertRows(String table, List<List<FieldValue>> rows) {
    if (rows.isEmpty) return [];
    List<FieldValue> firstRow = rows.first;
    List<FieldValue> uniqueList = firstRow.filter((e) => e.field.primaryKey || e.field.unique);
    List<FieldValue> otherList = firstRow.filter((e) => !e.field.primaryKey && !e.field.unique);

    String sql = "INSERT INTO ${table.escapeSQL} (${firstRow.map((e) => e.field.nameSQL).join(", ")}) VALUES ( ${firstRow.map((e) => '?').join(", ")} )";
    if (uniqueList.isNotEmpty) {
      List<String> conflicts = uniqueList.mapList((e) => e.field.nameSQL);
      if (otherList.isEmpty) {
        sql += " ON CONFLICT (${conflicts.join(", ")}) DO NOTHING";
      } else {
        sql += " ON CONFLICT (${conflicts.join(", ")}) DO UPDATE SET ${otherList.map((e) => "${e.field.nameSQL} = ?").join(", ")}";
      }
    }
    logd(sql);
    List<int> rowids = [];
    PreparedStatement st = prepareSQL(sql);
    for (var row in rows) {
      List<FieldValue> uniqueList = row.filter((e) => e.field.primaryKey || e.field.unique);
      List<FieldValue> otherList = row.filter((e) => !e.field.primaryKey && !e.field.unique);
      List<dynamic> argList = row.mapList((e) => e.value);
      if (uniqueList.isNotEmpty && otherList.isNotEmpty) {
        argList.addAll(otherList.map((e) => e.value));
      }
      logd(argList);
      st.execute(argList);
      rowids.add(db.lastInsertRowId);
    }
    st.dispose();
    return rowids;
  }

  int upsert(String table, List<FieldValue> row) {
    return upsertRows(table, [row]).firstOrNull ?? 0;
  }

  List<int> insertRows(String table, List<List<LabelValue<dynamic>>> rows, {InsertOption? conflict}) {
    if (rows.isEmpty) return List.empty();
    var firstRow = rows.first;
    String cs = conflict == null ? "" : "OR ${conflict.conflict}";
    String sql = "INSERT $cs INTO ${table.escapeSQL} (${firstRow.map((e) => e.label.escapeSQL).join(",")}) VALUES (${firstRow.map((e) => '?').join(",")})";
    PreparedStatement st = prepareSQL(sql);
    List<int> idList = [];
    for (var oneRow in rows) {
      st.execute(oneRow.mapList((e) => e.value));
      idList.add(db.lastInsertRowId);
    }
    st.dispose();
    return idList;
  }

  int insertRow(String table, List<LabelValue<dynamic>> row, {InsertOption? conflict}) {
    return insertRows(table, [row], conflict: conflict).first;
  }

  int insert(String table, List<String> columns, List<dynamic> row, {InsertOption? conflict}) {
    return insertMulti(table, columns, [row], conflict: conflict);
  }

  int insertMulti(String table, List<String> columns, List<List<dynamic>> rows, {InsertOption? conflict}) {
    String cs = conflict == null ? "" : "OR ${conflict.conflict}";
    String sql = "INSERT $cs INTO ${table.escapeSQL} (${columns.map((e) => e.escapeSQL).join(",")}) VALUES (${columns.map((e) => '?').join(",")})";
    PreparedStatement st = prepareSQL(sql);
    for (var row in rows) {
      st.execute(row);
    }
    st.dispose();
    return db.lastInsertRowId;
  }

  void transaction(void Function() callback) {
    db.execute("BEGIN");
    try {
      callback();
      db.execute("COMMIT");
    } catch (e) {
      db.execute("ROLLBACK");
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
    ResultSet rs = db.select(sql);
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
    ResultSet rs = db.select(sql);
    return rs.mapList((e) => e['name']);
  }

  List<IndexName> listIndex() {
    String sql = "SELECT  tbl_name , name FROM sqlite_master WHERE type='index'";
    ResultSet rs = db.select(sql);
    return rs.mapList((r) => IndexName(table: r.columnAt(0), index: r.columnAt(1)));
  }

  List<String> listTable() {
    String sql = "SELECT name FROM sqlite_master WHERE type = 'table'";
    ResultSet rs = db.select(sql);
    return rs.mapList((r) => r.columnAt(0));
  }

  bool existTable(String table) {
    String sql = "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ${table.singleQuoted}";
    ResultSet rs = db.select(sql);
    return rs.isNotEmpty;
  }

  int countTable(String table) {
    String sql = "SELECT count(*) FROM ${table.escapeSQL}";
    ResultSet rs = db.select(sql);
    return rs.firstOrNull?.columnAt(0) ?? 0;
  }

  void dropTable(String table) {
    String sql = "DROP TABLE IF EXISTS ${table.escapeSQL}";
    db.execute(sql);
  }

  void dropIndex(String table, String fieldName) {
    String idx = makeIndexName(table, [fieldName]);
    String sql = "DROP INDEX IF EXISTS $idx";
    db.execute(sql);
  }

  void addColumn(String table, FieldProto field) {
    String sql = "ALTER TABLE ${table.escapeSQL} ADD COLUMN ${field.defineField(false)}";
    db.execute(sql);
  }

  void createIndex(String table, List<String> fields) {
    String idxName = makeIndexName(table, fields);
    String sql = "CREATE INDEX IF NOT EXISTS $idxName ON ${table.escapeSQL} (${fields.map((e) => e.escapeSQL).join(",")})";
    println(sql);
    db.execute(sql);
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
    println(sql);
    db.execute(sql);

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

enum InsertOption {
  abort("ABORT"),
  fail("FAIL"),
  ignore("IGNORE"),
  replace("REPLACE"),
  rollback("ROLLBACK");

  const InsertOption(this.conflict);

  final String conflict;
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
