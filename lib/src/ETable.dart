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
mixin ETable<T> on Enum {
  Type get tableType => T;

  String get tableName => "$T";

  List<T> get columns;

  EColumn get column;

  String get nameColumn => column.name ?? this.name;

  String get nameSQL => (column.name ?? this.name).escapeSQL;
}

extension<T> on ETable<T> {
  FieldSQL toFieldSqL() {
    EColumn col = column;
    FieldSQL field = FieldSQL(
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
