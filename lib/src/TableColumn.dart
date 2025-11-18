part of 'sql.dart';

mixin TableColumn<T extends Enum> on Enum {
  Type get tableType => T;

  String get tableName => exGetOrPut("tableName", () {
    String a = "$T";
    if (a == "Object") errorSQL("TableColumn MUST has a generic type parameter. forexample:  enum Person with TableColumn<Person> ");
    return a;
  });

  List<T> get columns;

  ColumnSQL get column;

  String get nameColumn => exGetOrPut("nameColumn", () => (column.rename ?? this.name));

  String get nameSQL => exGetOrPut("nameSQL", () => nameColumn.escapeSQL);

  String get fullname => exGetOrPut("fullname", () => "${tableName.escapeSQL}.$nameSQL");

  FieldProto get proto => exGetOrPut("proto", () => _toFieldSqL());
}

extension TableColumnGetSetEx<T extends Enum> on TableColumn<T> {
  V? get<V>(Object? container) {
    if (container == null) return null;
    return _getModelValue(container, this.nameColumn);
  }

  void set(Object model, dynamic value) {
    _setModelValue(model, this.nameColumn, value);
  }

  FieldProto _toFieldSqL() {
    ColumnSQL col = column;
    FieldProto field = FieldProto(
      name: this.nameColumn,
      type: col.type ?? "TEXT",
      primaryKey: col.primaryKey,
      autoInc: col.autoInc,
      unique: col.unique,
      notNull: col.notNull,
      defaultValue: col.defaultValue,
      check: col.check,
      uniqueName: col.uniqueName,
      index: col.index,
    );
    return field;
  }
}
