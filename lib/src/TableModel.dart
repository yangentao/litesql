part of 'sql.dart';

class TableModel<E> {
  AnyMap model;
  final Type _tableType = E;
  final Set<String> _modifiedKeys = {};
  late final TableProto _proto = TableProto.of(_tableType);

  TableModel(this.model);

  SingleTable get _mtable {
    if (E == Object) errorSQL("TableModel<T>, generic type parameter MUST be set");
    return SingleTable(E);
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
    return _mtable.delete(_keyWhere);
  }

  /// update modified fields within callback by key(s),
  int update(VoidCallback callback) {
    _modifiedKeys.clear();
    callback();
    if (_modifiedKeys.isEmpty) return 0;
    List<ColumnValue> values = [];
    for (String k in _modifiedKeys) {
      TableColumn f = _proto.columns.firstWhere((e) => e.columnName == k);
      if (!f.proto.primaryKey) {
        values.add(f >> get(k));
      }
    }
    _modifiedKeys.clear();
    if (values.isEmpty) return 0;

    Returning ret = Returning.ALL;
    int n = _mtable.update(values: values, where: _keyWhere, returning: ret);
    if (n > 0) {
      this.model.addAll(ret.firstRow);
    }
    return n;
  }

  int updateByKey({List<Object>? columns, List<Object>? excludes}) {
    SingleTable tab = _mtable;
    List<MapEntry<TableColumn, dynamic>> values = _fieldValues(columns: columns, excludes: excludes);
    values.removeWhere((e) => e.key.proto.primaryKey);
    if (values.isEmpty) return 0;
    Returning ret = Returning.ALL;
    int n = tab.update(values: values, where: _keyWhere, returning: ret);
    if (n > 0) {
      this.model.addAll(ret.firstRow);
    }
    return n;
  }

  int insert({List<Object>? columns, List<Object>? excludes, InsertOption? conflict}) {
    List<ColumnValue> ls = _fieldValues(columns: columns, excludes: excludes);
    if (ls.isEmpty) return 0;
    Returning ret = Returning.ALL;
    SingleTable tab = _mtable;
    int id = tab.insert(ls, conflict: conflict, returning: ret);
    if (tab.lite.updatedRows > 0) {
      this.model.addAll(ret.firstRow);
    }
    return id;
  }

  int upsert({List<Object>? columns, List<Object>? excludes, InsertOption? conflict}) {
    List<ColumnValue> ls = _fieldValues(columns: columns, excludes: excludes);
    if (ls.isEmpty) return 0;
    Returning ret = Returning.ALL;
    var tab = _mtable;
    int id = tab.upsert(ls, returning: ret);
    if (tab.lite.updatedRows > 0) {
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

  String toJson() {
    return json.encode(model);
  }

  @override
  String toString() {
    return json.encode(model);
  }
}
