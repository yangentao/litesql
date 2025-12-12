part of '../sql.dart';

class TableProto {
  final Type type;
  final String name;
  final LiteSQL lite;
  final List<TableColumn> columns;

  late final String nameSQL = name.escapeSQL;
  late final List<TableColumn> primaryKeys = columns.filter((e) => e.proto.primaryKey);

  TableProto._(this.columns, {required this.lite, required this.type, String? tableName}) : name = tableName ?? "$type" {
    assert(columns.isNotEmpty);
    for (var e in columns) {
      e._tableProto = this;
    }
    _enumTypeMap[type] = this;
  }

  factory TableProto(Type type) {
    TableProto? p = _enumTypeMap[type];
    if (p == null) {
      errorSQL("NO table proto of '$type ' found, migrate it first. for example: liteSQL.migrate(Person.values) ");
    }
    return p;
  }

  TableColumn? find(String fieldName) {
    return columns.firstWhere((e) => e.columnName == fieldName);
  }

  // after migrate
  static TableProto of(Type type) {
    return TableProto(type);
  }

  static bool isRegistered<T>() => _enumTypeMap.containsKey(T);

  static final Map<Type, TableProto> _enumTypeMap = {};

  static void register<T extends TableColumn>(LiteSQL lite, List<T> fields, {String? tableName, dynamic Function(TableProto)? migrator = BasicMigrator.new}) {
    assert(fields.isNotEmpty);
    if (TableProto.isRegistered<T>()) return;
    TableProto tab = TableProto._(tableName: tableName, type: T, fields, lite: lite);
    if (migrator != null) {
      migrator(tab);
    }
  }
}

TableProto $(Type type) => TableProto.of(type);

TableProto PROTO(Type type) => TableProto.of(type);
