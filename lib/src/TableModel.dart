part of 'sql.dart';

class TableModel {
  MapSQL model;
  final Set<String> _modifiedKeys = {};

  TableModel(this.model);

  // TableModel.empty() : this({});

  dynamic operator [](Object key) {
    return get(key);
  }

  void operator []=(Object key, dynamic value) {
    set(key, value);
  }

  T? get<T>(Object key) {
    String k = key is TableColumn ? key.name : key.toString();
    var v = model[k];
    return _checkNum(v);
  }

  void set<T>(Object key, T? value) {
    String k = key is TableColumn ? key.name : key.toString();
    model[k] = value;
    _modifiedKeys.add(k);
  }

  String toJson() {
    return json.encode(model);
  }

  @override
  String toString() {
    return json.encode(model);
  }
}
