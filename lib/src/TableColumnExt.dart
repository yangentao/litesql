part of 'sql.dart';

extension TableColumnPropEx<T extends Enum> on TableColumn<T> {
  static final Map<Enum, Map<String, dynamic>> _columnPropMap = {};

  Map<String, dynamic> get propMap => _columnPropMap.getOrPut(this, () => <String, dynamic>{});

  V exGetOrPut<V>(String key, V Function() onMiss) {
    return propMap.getOrPut(key, onMiss);
  }

  V? exGet<V>(String key) {
    return propMap[key];
  }

  void exSet(String key, dynamic value) => propMap[key] = value;
}

extension ETableSQLExt<T extends Enum> on TableColumn<T> {
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

// where
extension WhereEnum<T extends Enum> on TableColumn<T> {
  Where EQ(dynamic value) {
    return Where(this.nameSQL, OpSQL.eq, value);
  }

  Where IN(AnyList values) {
    var a = values.map((e) => "?").join(",");
    return Where.raw("${this.nameSQL} IN ($a) ", values);
  }

  Where NE(dynamic value) {
    return Where(nameSQL, OpSQL.ne, value);
  }

  Where GE(dynamic value) {
    return Where(nameSQL, OpSQL.ge, value);
  }

  Where LE(dynamic value) {
    return Where(nameSQL, OpSQL.le, value);
  }

  Where GT(dynamic value) {
    return Where(nameSQL, OpSQL.gt, value);
  }

  Where LT(dynamic value) {
    return Where(nameSQL, OpSQL.lt, value);
  }

  Where LIKE(dynamic value) {
    return Where(nameSQL, OpSQL.like, value);
  }
}
