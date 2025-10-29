part of 'sql.dart';

class ModelSQL {
  MapSQL mapSQL;

  ModelSQL(this.mapSQL);

  ModelSQL.empty() : this({});

  T? get<T>(String key) {
    var v = mapSQL[key];
    return _checkNum(v);
  }

  void set<T>(String key, T? value) {
    mapSQL[key] = value;
  }

  @override
  String toString() {
    return json.encode(mapSQL);
  }
}
