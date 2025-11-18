part of 'sql.dart';

class TableProto {
  final String name;
  final List<TableColumn> fields;
  final String nameSQL;
  LiteSQL? liteSQL;

  TableProto(this.name, this.fields) : nameSQL = name.escapeSQL {
    for (var e in fields) {
      e.tableProto = this;
    }
  }

  TableColumn? find(String fieldName) {
    return fields.firstWhere((e) => e.name == fieldName);
  }

  // after migrate
  static TableProto of(Type type) => _requireTableProto(type);
}
