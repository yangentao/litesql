part of 'sql.dart';

extension FieldSQLValue on FieldProto {
  FieldValue operator >>(dynamic value) {
    return FieldValue(this, value);
  }
}

class FieldValue {
  FieldProto field;
  dynamic value;
  bool express;

  FieldValue(this.field, this.value, {this.express = false});
}

// https://sqlite.org/lang_keywords.html
extension StringSQLExt on String {
  String get braced {
    if (this.length >= 2 && this[0] == '(' && this[length - 1] == ')') return this;
    return "($this)";
  }

  String get escapeSQL {
    if (!this._shouldEscapeSQL) return this;
    return "\"$this\"";
  }

  String get unescapeSQL {
    if (this.length > 1 && this.startsWith("\"") && this.endsWith("\"")) {
      return this.substring(1, this.length - 1);
    }
    return this;
  }
}

T? _checkNum<T>(dynamic v) {
  if (v == null) return null;
  if (v is num) {
    if (T == int) {
      return v.toInt() as T;
    } else if (T == double) {
      return v.toDouble() as T;
    }
  }
  return v;
}

extension SqliteEscapeExt on String {
  bool get _shouldEscapeSQL => _sqlite_keywords.contains(this.toLowerCase());
}

Set<String> _SQLITE_KEYWORDS = _keywordString.split("\n").map((e) => e.trim()).filter((e) => e.isNotEmpty).toSet();
Set<String> _sqlite_keywords = _SQLITE_KEYWORDS.map((e) => e.toLowerCase()).toSet();
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
