part of 'sql.dart';

ArgSQL? mergeArgs(ArgSQL? a, ArgSQL? b) {
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

extension ResultSetExt on ResultSet {
  dynamic get oneValue {
    return this.firstOrNull?.firstValue;
  }

  JsonValue get oneJson {
    return this.firstOrNull?.jsonValue ?? JsonValue.nullValue;
  }

  List<JsonValue> get listJson {
    return this.mapList((e) => e.jsonValue);
  }

  void dump() {
    if (this.isEmpty) {
      println("[empty]");
      return;
    }
    for (Row r in this) {
      String s = r.entries.map((e) => "${e.key}: ${e.value}").join(", ");
      println(s);
    }
  }
}

extension RowExt on Row {
  JsonValue get jsonValue {
    List<String> labels = this.keys;
    List<dynamic> values = this.values;
    JsonMap map = {};
    for (int i = 0; i < labels.length; ++i) {
      map[labels[i]] = values[i];
    }
    return JsonValue(map);
  }

  dynamic get firstValue {
    return this.columnAt(0);
  }
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
