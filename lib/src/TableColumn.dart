part of 'sql.dart';

mixin TableColumn<T extends Enum> on Enum {
  Type get tableType => T;

  String get tableName => exPropGetOrPut("tableName", () {
    String a = "$T";
    if (a == "Object") errorSQL("TableColumn MUST has a generic type parameter. forexample:  enum Person with TableColumn<Person> ");
    return a;
  });

  List<T> get columns;

  ColumnProperties get column;

  String get nameColumn => exPropGetOrPut("nameColumn", () => (column.rename ?? this.name));

  String get nameSQL => exPropGetOrPut("nameSQL", () => nameColumn.escapeSQL);

  String get fullname => exPropGetOrPut("fullname", () => "${tableName.escapeSQL}.$nameSQL");

  ColumnProto get _proto => exPropGetOrPut("proto", () => _toFieldSqL());

  ColumnProto _toFieldSqL() {
    ColumnProperties col = column;
    ColumnProto field = ColumnProto(this.nameColumn, col);
    return field;
  }

  Map<String, dynamic> get _propMap => _columnPropMap.getOrPut(this, () => <String, dynamic>{});

  V exPropGetOrPut<V>(String key, V Function() onMiss) {
    return _propMap.getOrPut(key, onMiss);
  }

  V? exPropGet<V>(String key) {
    return _propMap[key];
  }

  void exPropSet(String key, dynamic value) => _propMap[key] = value;

  V? get<V>(Object? container) {
    if (container == null) return null;
    return _getModelValue(container, this.nameColumn);
  }

  void set(Object model, dynamic value) {
    _setModelValue(model, this.nameColumn, value);
  }

  FieldValue operator >>(dynamic value) {
    return FieldValue(this._proto, value);
  }
}

final Map<Enum, Map<String, dynamic>> _columnPropMap = {};
