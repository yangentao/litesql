part of 'sql.dart';

class TableProto {
  final String name;
  final List<ColumnProto> fields;
  final String nameSQL;
  LiteSQL? liteSQL;

  TableProto(this.name, this.fields) : nameSQL = name.escapeSQL {
    for (var e in fields) {
      e.table = this;
    }
  }

  ColumnProto? find(String fieldName) {
    return fields.firstWhere((e) => e.name == fieldName);
  }

  // after migrate
  static TableProto of(Type type) => _requireTableProto(type);
}

/// https://sqlite.org/datatype3.html
class ColumnProto extends ColumnProperties {
  final String name;
  final String nameSQL;
  late final TableProto table;
  late final String fullname = "${table.nameSQL}.$nameSQL";

  ColumnProto(this.name, ColumnProperties properties)
    : nameSQL = name.escapeSQL,
      super(
        type: properties.type,
        rename: properties.rename,
        primaryKey: properties.primaryKey,
        autoInc: properties.autoInc,
        unique: properties.unique,
        notNull: properties.notNull,
        defaultValue: properties.defaultValue,
        check: properties.check,
        uniqueName: properties.uniqueName,
        index: properties.index,
      );

  String defineField(bool multiKey) {
    List<String> ls = [nameSQL];
    ls << type;
    if (primaryKey && !multiKey) {
      ls << "PRIMARY KEY";
      if (autoInc) {
        ls << "AUTOINCREMENT";
      }
    }
    if (!primaryKey && !multiKey) {
      if (unique) {
        ls << "UNIQUE";
      }
      if (notNull) {
        ls << "NOT NULL";
      }
    }
    if (defaultValue != null && defaultValue!.isNotEmpty) {
      ls << "DEFAULT $defaultValue";
    }
    if (check != null && check!.isNotEmpty) {
      ls << "CHECK ($check)";
    }
    return ls.join(" ");
  }

  T? get<T>(Object model) {
    return _getModelValue(model, this.name);
  }

  void set(Object model, dynamic value) {
    _setModelValue(model, this.name, value);
  }
}

class INTEGER extends ColumnProperties {
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

class REAL extends ColumnProperties {
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

class NUMERIC extends ColumnProperties {
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

class TEXT extends ColumnProperties {
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

class BLOB extends ColumnProperties {
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

class ColumnProperties {
  final String type;
  final String? rename;
  final bool primaryKey;
  final bool autoInc; //AUTOINCREMENT
  final bool unique;
  final bool notNull;
  final String? defaultValue;
  final String? check;
  final String? uniqueName;
  final bool index;

  const ColumnProperties({
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
