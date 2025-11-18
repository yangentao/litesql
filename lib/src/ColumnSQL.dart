part of 'sql.dart';

class INTEGER extends ColumnSQL {
  const INTEGER({
    super.name,
    super.type = "INTEGER",
    super.primaryKey = false,
    super.notNull = false,
    super.autoInc = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
  });
}

class REAL extends ColumnSQL {
  const REAL({
    super.name,
    super.type = "REAL",
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
  });
}

class NUMERIC extends ColumnSQL {
  const NUMERIC({
    super.name,
    super.type = "NUMERIC",
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
  });
}

class TEXT extends ColumnSQL {
  const TEXT({
    super.name,
    super.type = "TEXT",
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
  });
}

class BLOB extends ColumnSQL {
  const BLOB({
    super.name,
    super.type = "BLOB",
    super.primaryKey = false,
    super.notNull = false,
    super.unique = false,
    super.index = false,
    super.check,
    super.uniqueName,
    super.defaultValue,
  });
}

class ColumnSQL {
  final String? name;
  final String? type;
  final bool primaryKey;
  final bool autoInc; //AUTOINCREMENT
  final bool unique;
  final bool notNull;
  final String? defaultValue;
  final String? check;
  final String? uniqueName;
  final bool index;

  const ColumnSQL({
    this.name,
    this.type,
    this.primaryKey = false,
    this.notNull = false,
    this.autoInc = false,
    this.unique = false,
    this.index = false,
    this.check,
    this.uniqueName,
    this.defaultValue,
  });
}
