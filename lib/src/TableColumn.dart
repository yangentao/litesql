part of 'sql.dart';

typedef ColumnValue = ({TableColumn column, dynamic value});

/// don't use 'name', use 'columnName',  enum's name maybe renamed.
mixin TableColumn<T extends Enum> on Enum {
  Type get tableType => T;

  String get tableName => exGetOrPut("tableName", () {
    String a = "$T";
    if (a == "Object") errorSQL("TableColumn MUST has a generic type parameter. forexample:  enum Person with TableColumn<Person> ");
    return a;
  });

  List<T> get columns;

  ColumnProto get proto;

  String get columnName => exGetOrPut("nameColumn", () => (proto.rename ?? this.name));

  String get nameSQL => exGetOrPut("nameSQL", () => columnName.escapeSQL);

  String get fullname => exGetOrPut("fullname", () => "${tableName.escapeSQL}.$nameSQL");

  TableProto get tableProto => exGet("tableProto");

  set tableProto(TableProto p) {
    exSet("tableProto", p);
  }

  Map<String, dynamic> get _propMap => _columnPropMap.getOrPut(this, () => <String, dynamic>{});

  V exGetOrPut<V>(String key, V Function() onMiss) {
    return _propMap.getOrPut(key, onMiss);
  }

  V? exGet<V>(String key) {
    return _propMap[key];
  }

  void exSet(String key, dynamic value) => _propMap[key] = value;

  V? get<V>(Object? container) {
    if (container == null) return null;
    return _getModelValue(container, this.columnName);
  }

  void set(Object model, dynamic value) {
    _setModelValue(model, this.columnName, value);
  }

  ColumnValue operator >>(dynamic value) {
    return (column: this, value: value);
  }

  String defineField(bool multiKey) {
    List<String> ls = [nameSQL];
    ls << proto.type;
    if (proto.primaryKey && !multiKey) {
      ls << "PRIMARY KEY";
      if (proto.autoInc) {
        ls << "AUTOINCREMENT";
      }
    }
    if (!proto.primaryKey && !multiKey) {
      if (proto.unique) {
        ls << "UNIQUE";
      }
      if (proto.notNull) {
        ls << "NOT NULL";
      }
    }
    if (proto.defaultValue != null && proto.defaultValue!.isNotEmpty) {
      ls << "DEFAULT ${proto.defaultValue}";
    }
    if (proto.check != null && proto.check!.isNotEmpty) {
      ls << "CHECK (${proto.check})";
    }
    return ls.join(" ");
  }
}

final Map<Enum, Map<String, dynamic>> _columnPropMap = {};

/// https://sqlite.org/datatype3.html
class INTEGER extends ColumnProto {
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

class REAL extends ColumnProto {
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

class NUMERIC extends ColumnProto {
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

class TEXT extends ColumnProto {
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

class BLOB extends ColumnProto {
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

class ColumnProto {
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

  const ColumnProto({
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
