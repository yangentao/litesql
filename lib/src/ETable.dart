part of 'sql.dart';

mixin ETable<T> on Enum {
  Type get tableType => T;

  String get tableName => "$T";

  List<T> get columns;

  EColumn get column;
}

extension<T> on ETable<T> {
  FieldSQL toFieldSqL() {
    EColumn col = column;
    FieldSQL field = FieldSQL(
      name: col.name ?? this.name,
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
