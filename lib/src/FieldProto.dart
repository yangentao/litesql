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
  }) : nameSQL = name.shouldEscapeSQL ? name.escapeSQL : name;

  FieldProto.text({
    required this.name,
    this.primaryKey = false,
    this.unique = false,
    this.notNull = false,
    this.index = false,
    this.uniqueName,
    this.check,
    String? defaultValue,
  })  : type = "TEXT",
        defaultValue = defaultValue == null ? null : "'$defaultValue'",
        autoInc = false,
        nameSQL = name.shouldEscapeSQL ? name.escapeSQL : name;

  FieldProto.integer({
    required this.name,
    this.primaryKey = false,
    this.unique = false,
    this.notNull = false,
    this.index = false,
    this.autoInc = false,
    this.uniqueName,
    this.check,
    int? defaultValue,
  })  : type = "INTEGER",
        defaultValue = defaultValue?.toString(),
        nameSQL = name.shouldEscapeSQL ? name.escapeSQL : name;

  FieldProto.real({required this.name, this.notNull = false, this.index = false, this.check, double? defaultValue})
      : type = "REAL",
        autoInc = false,
        primaryKey = false,
        unique = false,
        uniqueName = null,
        defaultValue = defaultValue?.toString(),
        nameSQL = name.shouldEscapeSQL ? name.escapeSQL : name;

  FieldProto.blob({required this.name, this.notNull = false, this.check, this.defaultValue})
      : type = "BLOB",
        autoInc = false,
        primaryKey = false,
        unique = false,
        uniqueName = null,
        index = false,
        nameSQL = name.shouldEscapeSQL ? name.escapeSQL : name;

  FieldProto.numberic({required this.name, this.notNull = false, this.index = false, this.check, int? defaultValue})
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
