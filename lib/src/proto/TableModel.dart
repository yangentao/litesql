part of '../sql.dart';

class TableModel<E> {
  AnyMap model;
  final Type _tableType = E;
  final Set<String> _modifiedKeys = {};
  final TableProto _proto = TableProto.of(E);

  TableModel(this.model);

  LiteSQL get _lite => _proto.lite;

  String get _tableName => _proto.name;

  void dumpTable() {
    _lite.dump(_tableType);
  }

  void clearModifyFlag() {
    _modifiedKeys.clear();
  }

  Where get _keyWhere {
    List<TableColumn> pks = _proto.primaryKeys;
    if (pks.isEmpty) errorSQL("No primary key defined");
    List<Where> wherePks = [];
    for (TableColumn f in pks) {
      dynamic v = get(f.columnName);
      if (v == null) errorSQL("Primary key is null: ${f.columnName}");
      wherePks.add(f.EQ(v));
    }
    return wherePks.and();
  }

  int delete() {
    return _lite.delete(_tableName, where: _keyWhere);
  }

  /// update modified fields within callback by key(s),
  int update(VoidCallback callback) {
    _modifiedKeys.clear();
    callback();
    if (_modifiedKeys.isEmpty) return 0;
    _modifiedKeys.clear();
    var ls = _modifiedKeys.toList();
    return updateByKey(columns: ls);
  }

  int updateByKey({List<Object>? columns, List<Object>? excludes}) {
    List<MapEntry<TableColumn, dynamic>> values = _fieldValues(columns: columns, excludes: excludes);
    values.removeWhere((e) => e.key.proto.primaryKey);
    values.retainWhere((e) => e.value != null || true == columns?.contains(e.key.columnName));
    if (values.isEmpty) return 0;
    Returning ret = Returning.ALL;
    int n = _lite.update(_tableName, values: values, where: _keyWhere, returning: ret);
    if (n > 0) {
      this.model.addAll(ret.firstRow);
    }
    return n;
  }

  // only nonull field will be insert, or 'columns' contains it
  int insert({List<Object>? columns, List<Object>? excludes, InsertOption? conflict}) {
    List<MapEntry<TableColumn, dynamic>> ls = _fieldValues(columns: columns, excludes: excludes);
    ls.retainWhere((e) => e.value != null || true == columns?.contains(e.key.columnName));
    if (ls.isEmpty) return 0;
    Returning ret = Returning.ALL;
    int id = _lite.insert(_tableName, values: ls, conflict: conflict, returning: ret);
    if (ret.hasReturn) {
      this.model.addAll(ret.firstRow);
    }
    return id;
  }

  // only nonull field will be insert, or 'columns' contains it
  int upsert({List<Object>? columns, List<Object>? excludes, InsertOption? conflict}) {
    List<MapEntry<TableColumn, dynamic>> ls = _fieldValues(columns: columns, excludes: excludes);
    ls.retainWhere((e) => e.value != null || true == columns?.contains(e.key.columnName));
    if (ls.isEmpty) return 0;
    Returning ret = Returning.ALL;
    int id = _lite.upsert(_tableName, values: ls, constraints: _proto.primaryKeys, returning: ret);
    if (ret.hasReturn) {
      this.model.addAll(ret.firstRow);
    }
    _modifiedKeys.clear();
    return id;
  }

  List<MapEntry<TableColumn, dynamic>> _fieldValues({List<Object>? columns, List<Object>? excludes}) {
    List<String>? names = columns?.mapList((e) => _columnNameOf(e));
    List<String> excludeNames = excludes?.mapList((e) => _columnNameOf(e)) ?? [];

    List<MapEntry<TableColumn, dynamic>> ls = [];
    if (names != null && names.isNotEmpty) {
      for (String f in names) {
        if (!excludeNames.contains(f)) {
          ls.add(_proto.find(f)! >> get(f));
        }
      }
    } else {
      for (TableColumn f in _proto.columns) {
        if (!excludeNames.contains(f.columnName)) {
          ls.add(f >> get(f));
        }
      }
    }
    return ls;
  }

  dynamic operator [](Object key) {
    return get(key);
  }

  void operator []=(Object key, dynamic value) {
    set(key, value);
  }

  T? get<T>(Object key) {
    String k = _columnNameOf(key);
    var v = model[k];
    return _checkNum<T>(v);
  }

  void set<T>(Object key, T? value) {
    String k = _columnNameOf(key);
    model[k] = value;
    _modifiedKeys.add(k);
  }

  Object? removeProperty(Object key) {
    String k = _columnNameOf(key);
    return model.remove(k);
  }

  String toJson() {
    return json.encode(model);
  }

  @override
  String toString() {
    return json.encode(model);
  }
}
