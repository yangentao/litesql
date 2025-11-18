part of 'sql.dart';

class TableProto {
  final String name;
  final List<FieldProto> fields;
  final String nameSQL;
  LiteSQL? liteSQL;

  TableProto(this.name, this.fields) : nameSQL = name.escapeSQL {
    for (var e in fields) {
      e.table = this;
    }
  }

  FieldProto? find(String fieldName) {
    return fields.firstWhere((e) => e.name == fieldName);
  }

  // after migrate
  static TableProto of(Type type) => _requireTableProto(type);
}
