part of 'sql.dart';

class ModelSQL {
  MapSQL mapSQL;

  ModelSQL(this.mapSQL);

  ModelSQL.empty() : this({});

  T? get<T>(String key) {
    var v = mapSQL[key];
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

  void set<T>(String key, T? value) {
    assert(value == null || value is bool || value is num || value is String || value is BlobSQL);
    mapSQL[key] = value;
  }

  @override
  String toString() {
    return json.encode(mapSQL);
  }
}
