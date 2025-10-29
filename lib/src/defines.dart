part of 'sql.dart';

typedef MapSQL = Map<String, dynamic>;
typedef BlobSQL = Uint8List;

class ModelSQL {
  MapSQL mapSQL;

  ModelSQL(this.mapSQL);

  T? getProp<T>(String key) {
    assert(T == bool || T == int || T == double || T == String || T == BlobSQL);
    return mapSQL[key];
  }

  void setProp<T>(String key, T? value) {
    assert(value == null || value is bool || value is int || value is double || value is String || value is BlobSQL);
    mapSQL[key] = value;
  }

  @override
  String toString() {
    return json.encode(mapSQL);
  }
}
