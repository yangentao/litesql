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
