part of 'sql.dart';

/// enum Person with ETable<Person> {
///   id(EColumn.integer(primaryKey: true)),
///   name(EColumn.text()),
///   addr(EColumn.text(name: "address")),
///   age(EColumn.integer());
///
///   const Person(this.column);
///
///   @override
///   final EColumn column;
///
///   @override
///   List<Person> get columns => Person.values;
/// }
mixin TableColumn<T> on Enum {
  Type get tableType => T;

  String get tableName => "$T";

  List<T> get columns;

  ColumnSQL get column;

  String get nameColumn => column.name ?? this.name;

  String get nameSQL => exGetOrPut("nameSQL", () => (column.name ?? this.name).escapeSQL);

  String get fullname => exGetOrPut("fullname", () => "${tableName.escapeSQL}.$nameSQL}");
}

extension TableColumnPropEx<T> on TableColumn<T> {
  static final Map<Enum, Map<String, dynamic>> _columnPropMap = {};

  Map<String, dynamic> get propMap => _columnPropMap.getOrPut(this, () => <String, dynamic>{});

  V exGetOrPut<V>(String key, V Function() onMiss) {
    return propMap.getOrPut(key, onMiss);
  }

  V? exGet<V>(String key) {
    return propMap[key];
  }

  void exSet(String key, dynamic value) => propMap[key] = value;
}

extension TableColumnGetSetEx<T> on TableColumn<T> {
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

  FieldProto toFieldSqL() {
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

extension ETableSQLExt<T> on TableColumn<T> {
  /// join on clause
  String EQUAL(FieldProto other) {
    return "${this.fullname} = ${other.fullname}";
  }

  String AS(String label) {
    return "${this.fullname} AS $label";
  }

  String MAX() {
    return "MAX($nameSQL)";
  }

  String MIN() {
    return "MIN($nameSQL)";
  }
}
