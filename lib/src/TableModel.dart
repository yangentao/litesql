part of 'sql.dart';

class TableModel {
  MapSQL mapSQL;

  TableModel(this.mapSQL);

  TableModel.empty() : this({});

  dynamic operator [](Object key) {
    return get(key);
  }

  void operator []=(Object key, dynamic value) {
    set(key, value);
  }

  T? get<T>(Object key) {
    String k = key is TableColumn ? key.name : key.toString();
    var v = mapSQL[k];
    return _checkNum(v);
  }

  void set<T>(Object key, T? value) {
    String k = key is TableColumn ? key.name : key.toString();
    mapSQL[k] = value;
  }

  @override
  String toString() {
    return json.encode(mapSQL);
  }
}
