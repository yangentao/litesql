part of 'sql.dart';

mixin TableColumn<T extends Enum> on Enum {
  Type get tableType => T;

  String get tableName => exGetOrPut("tableName", () {
        String a = "$T";
        if (a == "Object") throw SQLException("TableColumn MUST has a generic type parameter. forexample:  enum Person with TableColumn<Person> ");
        List<String> ls = TRIM_SUFFIXS;
        if (ls.isEmpty) return a;
        for (String s in ls) {
          if (s.isNotEmpty && a != s && a.endsWith(s)) return a.substringBeforeLast(s);
        }
        return a;
      });

  List<String> get TRIM_SUFFIXS => ["T", "Table"];

  List<T> get columns;

  ColumnSQL get column;

  String get nameColumn => exGetOrPut("nameColumn", () => (column.name ?? this.name));

  String get nameSQL => exGetOrPut("nameSQL", () => nameColumn.escapeSQL);

  String get fullname => exGetOrPut("fullname", () => "${tableName.escapeSQL}.$nameSQL}");

  FieldProto get proto => exGetOrPut("proto", () => _toFieldSqL());
}

extension TableColumnGetSetEx<T extends Enum> on TableColumn<T> {
  V? get<V>(Object? container) {
    if (container == null) return null;
    if (container is MapSQL) return container[this.nameColumn];
    if (container is TableModel) return container.get(this.nameColumn);
    if (container is JsonValue) return container[this.nameColumn].value;
    if (container is JsonModel) return container.jsonValue[this.nameColumn].value;
    throw SQLException("TableColumn get(). Unknown container: $container, tableColumn: $nameColumn");
  }

  void set(Object model, dynamic value) {
    if (model is TableModel) {
      model.set(this.nameColumn, value);
    } else if (model is MapSQL) {
      model[this.nameColumn] = value;
    } else if (model is JsonValue) {
      model[this.nameColumn] = value;
    } else if (model is JsonModel) {
      model.jsonValue[this.nameColumn] = value;
    } else {
      throw SQLException("TableColumn.set(), unknown container:$model, tableColumn:$nameColumn.");
    }
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
