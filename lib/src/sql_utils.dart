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

AnyList? _mergeArgs(AnyList? a, AnyList? b) {
  if (a == null) return b;
  if (b == null) return a;
  return a + b;
}

// https://sqlite.org/lang_keywords.html
extension StringSQLExt on String {
  String get braced {
    return "($this)";
  }

  String bracedIf(bool cond) {
    if (cond) return "($this)";
    return this;
  }

  String get escapeSQL {
    if (!this.shouldEscapeSQL) return this;
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
