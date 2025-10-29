part of 'sql.dart';

class ModelSQL {
  MapSQL mapSQL;

  ModelSQL(this.mapSQL);

  ModelSQL.empty() : this({});

  T? get<T>(Object key) {
    String k = key is ETable ? key.name : key.toString();
    var v = mapSQL[k];
    return _checkNum(v);
  }

  void set<T>(Object key, T? value) {
    String k = key is ETable ? key.name : key.toString();
    mapSQL[k] = value;
  }

  @override
  String toString() {
    return json.encode(mapSQL);
  }
}
