part of '../sql.dart';

class BasicMigrator {
  final TableProto tableProto;
  final String? schema;
  late final String schemaTable = tableProto.nameSQL._schema(schema);

  BasicMigrator(this.tableProto, {this.schema}) {
    migrate();
  }

  List<TableColumn> get fields => tableProto.columns;

  String get tableName => tableProto.name;

  LiteSQL get lite => tableProto.lite;

  String autoIncDefine(String type) {
    return "$type AUTOINCREMENT";
  }

  QueryResult execute(String sql, [AnyList? args]) {
    return lite.execute(sql, args);
  }

  Future<void> autoIncChangeBase(TableColumn field, int base) async {
    final seqTable = "sqlite_sequence"._schema(schema);
    final tab = tableName.escapeSQL;
    final rs = this.execute("SELECT name, seq FROM $seqTable WHERE name = $tab");
    if (rs.isNotEmpty) {
      this.execute("UPDATE $seqTable SET seq = $base WHERE name = $tab");
    } else {
      this.execute("INSERT INTO $seqTable(name, seq) VALUES( $tab, $base)");
    }
  }

  bool tableExists() {
    String sql = "SELECT 1 FROM ${"sqlite_schema"._schema(schema)} WHERE type = 'table' AND name = ?";
    QueryResult rs = execute(sql, [tableName]);
    return rs.isNotEmpty;
  }

  Set<String> tableFields() {
    QueryResult r = execute("PRAGMA ${"table_info"._schema(schema)}($tableName)");
    return r.listValues<String>("name").toSet();
  }

  Set<String> listIndex() {
    QueryResult r = execute("PRAGMA ${"index_list"._schema(schema)}($tableName)");
    return r.listValues<String>("name").toSet();
  }

  Set<String> indexFields(String indexName) {
    QueryResult r = execute("PRAGMA ${"index_info"._schema(schema)}($indexName)");
    return r.listValues<String>("name").toSet();
  }

  void migrate() {
    if (!tableExists()) {
      createTable();
      return;
    }
    Set<String> colSet = tableFields();
    for (TableColumn f in fields) {
      if (!colSet.contains(f.columnName)) {
        addColumn(f);
      }
    }
    Set<String> idxSet = {};
    Set<String> idxs = listIndex();
    for (String idx in idxs) {
      final fs = indexFields(idx);
      idxSet.addAll(fs);
    }
    for (TableColumn f in fields) {
      if (f.proto.primaryKey || f.proto.unique || notBlank(f.proto.uniqueName)) continue;
      if (f.proto.index && !idxSet.contains(f.columnName)) {
        createIndex([f.columnName]);
      }
    }
  }

  void createTable({List<String>? constraints, List<String>? options}) {
    SpaceBuffer buf = SpaceBuffer();
    buf << "CREATE TABLE IF NOT EXISTS $schemaTable (";
    buf << fields.map((e) => defineField(e)).join(", ");

    final pks = fields.filter((e) => e.proto.primaryKey);
    if (pks.isNotEmpty) {
      buf << ", " << "PRIMARY KEY (${pks.map((e) => e.nameSQL).join(", ")})";
    }
    final uniqeList = fields.filter((e) => e.proto.unique || e.proto.uniqueName != null);
    if (uniqeList.isNotEmpty) {
      Map<String, List<TableColumn>> map = uniqeList.groupBy((e) => e.proto.uniqueName | "");
      for (var e in map.entries) {
        if (e.key == "") {
          for (var c in e.value) {
            buf << ", " << "UNIQUE (${c.nameSQL})";
          }
        } else {
          buf << ", " << "CONSTRAINT " << e.key.escapeSQL << " UNIQUE (${e.value.map((f) => f.nameSQL).join(", ")})";
        }
      }
    }

    if (constraints != null && constraints.isNotEmpty) {
      for (var s in constraints) {
        buf << ", " << s;
      }
    }
    buf << ")";
    if (options != null && options.isNotEmpty) {
      buf << options.join(", ");
    }
    execute(buf.toString());

    final col = fields.firstOr((e) => e.proto.autoInc > 0);
    if (col != null) {
      autoIncChangeBase(col, col.proto.autoInc);
    }

    for (var f in fields) {
      if (f.proto.primaryKey || f.proto.unique || notBlank(f.proto.uniqueName)) {
        continue;
      }
      if (f.proto.index) {
        createIndex([f.columnName]);
      }
    }
  }

  void createIndex(List<String> fields) {
    String idxName = _makeIndexName(tableName, fields);
    String sql = "CREATE INDEX IF NOT EXISTS $idxName ON $schemaTable (${fields.map((e) => e.escapeSQL).join(",")})";
    execute(sql);
  }

  void addColumn(TableColumn field) {
    String sql = "ALTER TABLE $schemaTable ADD COLUMN ${defineField(field)}";
    execute(sql);
  }

  String defineField(TableColumn col) {
    ColumnProto proto = col.proto;
    SpaceBuffer buf = SpaceBuffer(col.nameSQL);

    if (proto.autoInc > 0) {
      buf << autoIncDefine(proto.type);
    } else {
      buf << proto.type;
    }
    if (proto.notNull) {
      buf << "NOT NULL";
    }
    if (proto.defaultValue.notEmpty) {
      buf << "DEFAULT" << proto.defaultValue!;
    }
    if (proto.check.notEmpty) {
      buf << "CHECK (" << proto.check! << ")";
    }
    if (proto.extras.notBlank) {
      buf << proto.extras!;
    }
    return buf.toString();
  }
}
