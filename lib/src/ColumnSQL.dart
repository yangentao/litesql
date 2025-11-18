part of 'sql.dart';

class INTEGER extends ColumnSQL {
  const INTEGER({
    super.rename,
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
    super.rename,
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
    super.rename,
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
    super.rename,
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
    super.rename,
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
  final String? rename;
  final String type;
  final bool primaryKey;
  final bool autoInc; //AUTOINCREMENT
  final bool unique;
  final bool notNull;
  final String? defaultValue;
  final String? check;
  final String? uniqueName;
  final bool index;

  const ColumnSQL({
    required this.type,
    this.rename,
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
