part of 'sql.dart';

class TableModel<E> {
  MapSQL model;
  Type tableType = E;

  // DType<T> dtype = DType<T>();
  final Set<String> _modifiedKeys = {};

  TableModel(this.model);

  // TableModel.empty() : this({});

  EnumTable _table() {
    if (E == Object) throw SQLException("TableModel<T>, generic type parameter MUST be set");
    return EnumTable.of(E);
  }

  void clearModifyFlag() {
    _modifiedKeys.clear();
  }

  int delete() {
    EnumTable tab = _table();
    List<FieldProto> pks = tab.primaryKeys();
    if (pks.isEmpty) throw SQLException("NO primary key defined.");
    List<Where> wherePks = [];
    for (FieldProto f in pks) {
      dynamic v = get(f.name);
      if (v == null) throw SQLException("Primary key is null: ${f.name}");
      wherePks.add(f.EQ(v));
    }
    if (wherePks.isEmpty) throw SQLException("NO primary key condition(s).");
    return tab.delete(wherePks.and());
  }

  int update(VoidCallback callback) {
    EnumTable tab = _table();
    List<FieldProto> pks = tab.primaryKeys();
    if (pks.isEmpty) throw SQLException("NO primary key defined.");
    _modifiedKeys.clear();
    callback();
    if (_modifiedKeys.isEmpty) return 0;
    List<Where> wherePks = [];
    for (FieldProto f in pks) {
      dynamic v = get(f.name);
      if (v == null) throw SQLException("Primary key is null: ${f.name}");
      wherePks.add(f.EQ(v));
    }

    List<FieldValue> values = [];
    for (String k in _modifiedKeys) {
      FieldProto f = tab.proto.fields.firstWhere((e) => e.name == k);
      if (!f.primaryKey) {
        values.add(f >> get(k));
      }
    }
    _modifiedKeys.clear();
    if (values.isEmpty) return 0;
    int n = tab.update(values, where: wherePks.and());

    return n;
  }

  int insert({InsertOption? conflict}) {
    EnumTable tab = _table();
    List<FieldValue> ls = [];
    for (String k in _modifiedKeys) {
      FieldProto f = tab.proto.fields.firstWhere((e) => e.name == k);
      ls.add(f >> get(k));
    }
    if (ls.isEmpty) return 0;
    int id = tab.insert(ls, conflict: conflict);
    if (id > 0) {
      var ls = tab.proto.fields.filter((e) => e.primaryKey && e.type.toUpperCase() == "INTEGER");
      if (ls.length == 1) {
        FieldProto p = ls.first;
        if (!_modifiedKeys.contains(p.name)) {
          set(p.name, id);
        }
      }
    }
    _modifiedKeys.clear();
    return id;
  }

  int upsert() {
    EnumTable tab = _table();
    List<FieldValue> ls = [];
    for (String k in _modifiedKeys) {
      FieldProto f = tab.proto.fields.firstWhere((e) => e.name == k);
      ls.add(f >> get(k));
    }

    if (ls.isEmpty) return 0;
    int id = tab.upsert(ls);
    if (id > 0) {
      var ls = tab.proto.fields.filter((e) => e.primaryKey && e.type.toUpperCase() == "INTEGER");
      if (ls.length == 1) {
        FieldProto p = ls.first;
        if (!_modifiedKeys.contains(p.name)) {
          set(p.name, id);
        }
      }
    }
    _modifiedKeys.clear();
    return id;
  }

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
