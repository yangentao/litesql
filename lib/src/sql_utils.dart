part of 'sql.dart';

ArgSQL? _mergeArgs(ArgSQL? a, ArgSQL? b) {
  if (a == null) return b;
  if (b == null) return a;
  return a + b;
}

extension FieldSQLValue on FieldSQL {
  FieldValue operator >>(dynamic value) {
    return FieldValue(this, value);
  }
}

class FieldValue {
  FieldSQL field;
  dynamic value;
  bool express;

  FieldValue(this.field, this.value, {this.express = false});
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
