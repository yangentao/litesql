part of 'sql.dart';

/// https://sqlite.org/datatype3.html
class FieldSQL {
  final String name;
  final String type; // TEXT, INTEGER, BLOB, REAL, (NUMERIC)
  final bool primaryKey;
  final bool autoInc; //AUTOINCREMENT
  final bool unique;
  final bool notNull;
  final String? defaultValue;
  final String? check;

  //
  final String? uniqueName;
  final bool index;

  // escaped
  final String nameSQL;

  late TableSQL table;

  String get fullname => "${table.nameSQL}.$nameSQL";

  FieldSQL({
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
  }) : nameSQL = name.shouldEscapeSQL ? name.escapeSQL : name;

  FieldSQL.text({
    required this.name,
    this.primaryKey = false,
    this.unique = false,
    this.notNull = false,
    this.index = false,
    this.uniqueName,
    this.check,
    String? defaultValue,
  }) : type = "TEXT",
       defaultValue = defaultValue == null ? null : "'$defaultValue'",
       autoInc = false,
       nameSQL = name.shouldEscapeSQL ? name.escapeSQL : name;

  FieldSQL.integer({
    required this.name,
    this.primaryKey = false,
    this.unique = false,
    this.notNull = false,
    this.index = false,
    this.autoInc = false,
    this.uniqueName,
    this.check,
    int? defaultValue,
  }) : type = "INTEGER",
       defaultValue = defaultValue?.toString(),
       nameSQL = name.shouldEscapeSQL ? name.escapeSQL : name;

  FieldSQL.real({required this.name, this.notNull = false, this.index = false, this.check, double? defaultValue})
    : type = "REAL",
      autoInc = false,
      primaryKey = false,
      unique = false,
      uniqueName = null,
      defaultValue = defaultValue?.toString(),
      nameSQL = name.shouldEscapeSQL ? name.escapeSQL : name;

  FieldSQL.blob({required this.name, this.notNull = false, this.check, this.defaultValue})
    : type = "BLOB",
      autoInc = false,
      primaryKey = false,
      unique = false,
      uniqueName = null,
      index = false,
      nameSQL = name.shouldEscapeSQL ? name.escapeSQL : name;

  FieldSQL.numberic({required this.name, this.notNull = false, this.index = false, this.check, int? defaultValue})
    : type = "NUMERIC",
      autoInc = false,
      primaryKey = false,
      unique = false,
      uniqueName = null,
      defaultValue = defaultValue?.toString(),
      nameSQL = name.shouldEscapeSQL ? name.escapeSQL : name;

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

  T? get<T>(Object? container) {
    Object? v = getValue(container);
    if (v == null) return null;
    if (T == int) {
      num? n = v as num?;
      return castValue(n?.toInt());
    }
    if (T == double) {
      num? n = v as num?;
      return castValue(n?.toDouble());
    }
    return castValue(v);
  }

  dynamic getValue(Object? container) {
    if (container == null) return null;
    if (container is JsonValue) {
      return container[this.name].value;
    }
    if (container is JsonModel) {
      return container.jsonValue[this.name].value;
    }
    if (container is JsonMap) {
      return container[this.name];
    }
    throw HareException("FieldSQL.get(), unknown container.");
  }

  void set(Object? container, dynamic value) {
    assert(value == null || value is num || value is String || value is bool || value is Uint8List);
    setValue(container, value);
  }

  void setValue(Object? container, dynamic value) {
    if (container == null) return;
    if (container is JsonMap) {
      container[this.name] = value;
    } else if (container is JsonValue) {
      container[this.name] = value;
    } else if (container is JsonModel) {
      container.jsonValue[this.name] = value;
    } else {
      throw HareException("FieldSQL.set(), unknown container.");
    }
  }

  /// join on clause
  String EQUAL(FieldSQL other) {
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

extension SqliteEscapeExt on String {
  bool get shouldEscapeSQL => sqlite_keywords.contains(this.toLowerCase());
}

Set<String> SQLITE_KEYWORDS = _keywordString.split("\n").map((e) => e.trim()).filter((e) => e.isNotEmpty).toSet();
Set<String> sqlite_keywords = SQLITE_KEYWORDS.map((e) => e.toLowerCase()).toSet();
String _keywordString = """
ABORT
ACTION
ADD
AFTER
ALL
ALTER
ANALYZE
AND
AS
ASC
ATTACH
AUTOINCREMENT
BEFORE
BEGIN
BETWEEN
BY
CASCADE
CASE
CAST
CHECK
COLLATE
COLUMN
COMMIT
CONFLICT
CONSTRAINT
CREATE
CROSS
CURRENT_DATE
CURRENT_TIME
CURRENT_TIMESTAMP
DATABASE
DEFAULT
DEFERRABLE
DEFERRED
DELETE
DESC
DETACH
DISTINCT
DROP
EACH
ELSE
END
ESCAPE
EXCEPT
EXCLUSIVE
EXISTS
EXPLAIN
FAIL
FOR
FOREIGN
FROM
FULL
GLOB
GROUP
HAVING
IF
IGNORE
IMMEDIATE
IN
INDEX
INDEXED
INITIALLY
INNER
INSERT
INSTEAD
INTERSECT
INTO
IS
ISNULL
JOIN
KEY
LEFT
LIKE
LIMIT
MATCH
NATURAL
NO
NOT
NOTNULL
NULL
OF
OFFSET
ON
OR
ORDER
OUTER
PLAN
PRAGMA
PRIMARY
QUERY
RAISE
RECURSIVE
REFERENCES
REGEXP
REINDEX
RELEASE
RENAME
REPLACE
RESTRICT
RIGHT
ROLLBACK
ROW
SAVEPOINT
SELECT
SET
TABLE
TEMP
TEMPORARY
THEN
TO
TRANSACTION
TRIGGER
UNION
UNIQUE
UPDATE
USING
VACUUM
VALUES
VIEW
VIRTUAL
WHEN
WHERE
WITH
WITHOUT
""";
