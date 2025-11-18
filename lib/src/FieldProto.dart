part of 'sql.dart';

/// https://sqlite.org/datatype3.html
class FieldProto {
  final String name;
  final String type; // TEXT, INTEGER, BLOB, REAL, (NUMERIC)
  final bool primaryKey;
  final bool autoInc; //AUTOINCREMENT
  final bool unique;
  final bool notNull;
  final String? defaultValue;
  final String? check;
  final String? uniqueName;
  final bool index;

  // escaped
  final String nameSQL;

  late TableProto table;

  String get fullname => "${table.nameSQL}.$nameSQL";

  FieldProto({
    required this.name,
    required this.type,
    this.primaryKey = false,
    this.unique = false,
    this.notNull = false,
    this.index = false,
    this.autoInc = false,
    this.uniqueName,
    this.defaultValue,
    this.check,
  }) : nameSQL = name._shouldEscapeSQL ? name.escapeSQL : name;

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
