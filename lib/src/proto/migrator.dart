part of '../sql.dart';

class BasicMigrator {
  final TableProto tableProto;

  BasicMigrator(this.tableProto) {
    _migrateTable();
  }

  LiteSQL get lite => tableProto.lite;

  String get tableName => tableProto.name;

  List<TableColumn> get fields => tableProto.columns;

  void _migrateTable() {
    if (!lite.existTable(tableName)) {
      _createTable();
      return;
    }

    List<SqliteTableInfo> cols = lite.tableInfo(tableName);
    Set<String> colSet = cols.map((e) => e.name).toSet();
    for (TableColumn f in fields) {
      if (!colSet.contains(f.columnName)) {
        _addColumn(f);
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

  void _addColumn(TableColumn field) {
    String sql = "ALTER TABLE ${tableName.escapeSQL} ADD COLUMN ${defineField(field, false)}";
    lite.execute(sql);
  }

  void _createTable({List<String>? constraints, List<String>? options, bool notExist = true}) {
    List<String> ls = [];
    if (notExist) {
      ls << "CREATE TABLE IF NOT EXISTS ${tableName.escapeSQL} (";
    } else {
      ls << "CREATE TABLE ${tableName.escapeSQL} (";
    }

    List<String> colList = [];

    List<TableColumn> keyFields = fields.filter((e) => e.proto.primaryKey);
    colList.addAll(fields.map((e) => defineField(e, keyFields.length > 1)));

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
        lite.createIndex(tableName, [f.columnName]);
      }
    }
  }

  String defineField(TableColumn column, bool multiKey) {
    ColumnProto proto = column.proto;
    List<String> ls = [column.nameSQL];
    ls << proto.type;
    if (proto.primaryKey && !multiKey) {
      ls << "PRIMARY KEY";
      if (proto.autoInc) {
        ls << "AUTOINCREMENT";
      }
    }
    if (!proto.primaryKey && !multiKey) {
      if (proto.unique) {
        ls << "UNIQUE";
      }
      if (proto.notNull) {
        ls << "NOT NULL";
      }
    }
    if (proto.defaultValue != null && proto.defaultValue!.isNotEmpty) {
      ls << "DEFAULT ${proto.defaultValue}";
    }
    if (proto.check != null && proto.check!.isNotEmpty) {
      ls << "CHECK (${proto.check})";
    }
    if (proto.extras.notBlank) {
      ls << proto.extras!;
    }
    return ls.join(" ");
  }
}
