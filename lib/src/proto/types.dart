part of '../sql.dart';

/// https://sqlite.org/datatype3.html
class INTEGER extends ColumnProto {
  const INTEGER(
      {super.name,
      super.type = "INTEGER",
      super.primaryKey = false,
      super.notNull = false,
      super.autoInc = false,
      super.unique = false,
      super.index = false,
      super.check,
      super.uniqueName,
      super.defaultValue,
      super.extras});
}

class REAL extends ColumnProto {
  const REAL(
      {super.name,
      super.type = "REAL",
      super.primaryKey = false,
      super.notNull = false,
      super.unique = false,
      super.index = false,
      super.check,
      super.uniqueName,
      super.defaultValue,
      super.extras});
}

class NUMERIC extends ColumnProto {
  const NUMERIC(
      {super.name,
      super.type = "NUMERIC",
      super.primaryKey = false,
      super.notNull = false,
      super.unique = false,
      super.index = false,
      super.check,
      super.uniqueName,
      super.defaultValue,
      super.extras});
}

class TEXT extends ColumnProto {
  const TEXT(
      {super.name,
      super.type = "TEXT",
      super.primaryKey = false,
      super.notNull = false,
      super.unique = false,
      super.index = false,
      super.check,
      super.uniqueName,
      super.defaultValue,
      super.extras});
}

class BLOB extends ColumnProto {
  const BLOB(
      {super.name,
      super.type = "BLOB",
      super.primaryKey = false,
      super.notNull = false,
      super.unique = false,
      super.index = false,
      super.check,
      super.uniqueName,
      super.defaultValue,
      super.extras});
}

class ColumnProto {
  final String type;
  final String? name;
  final bool primaryKey;
  final bool autoInc; //AUTOINCREMENT
  final bool unique;
  final bool notNull;
  final String? defaultValue;
  final String? check;
  final String? uniqueName;
  final bool index;
  final String? extras;

  const ColumnProto({
    required this.type,
    this.name,
    this.primaryKey = false,
    this.notNull = false,
    this.autoInc = false,
    this.unique = false,
    this.index = false,
    this.check,
    this.uniqueName,
    this.defaultValue,
    this.extras,
  });

  /// decode from database value to dart value
  Object? decode(Object? value) => value;

  /// encode datr value to database value
  Object? encode(Object? value) => value;
}
