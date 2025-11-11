part of 'sql.dart';

class TableModel<E> {
  MapSQL model;
  Type tableType = E;

  // DType<T> dtype = DType<T>();
  final Set<String> _modifiedKeys = {};

  TableModel(this.model);

  // TableModel.empty() : this({});

  EnumTable mtable() {
    if (E == Object) throw SQLException("TableModel<T>, generic type parameter MUST be set");
    return EnumTable.of(E);
  }

  void clearModifyFlag() {
    _modifiedKeys.clear();
  }

  /// delete by key
  int delete() {
    EnumTable tab = mtable();
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

  /// MPerson p = From(Person).oneByKey(MPerson.new , key: 1)!
  /// p.update((){
  ///   p.name = "new name";
  /// });
  /// ONLY update columns changed in callback.
  int update(VoidCallback callback) {
    EnumTable tab = mtable();
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

  int insert({InsertOption? conflict, List<TableColumn>? columns, List<String>? names}) {
    EnumTable tab = mtable();

    List<FieldValue> ls = [];
    if (columns != null && columns.isNotEmpty) {
      for (TableColumn f in columns) {
        ls.add(tab.proto.find(f.nameColumn)! >> get(f));
      }
    } else if (names != null && names.isNotEmpty) {
      for (String f in names) {
        ls.add(tab.proto.find(f)! >> get(f));
      }
    } else {
      for (FieldProto f in tab.proto.fields) {
        ls.add(f >> get(f));
      }
    }
    if (ls.isEmpty) return 0;
    int id = tab.insert(ls, conflict: conflict);
    if (id > 0) {
      var ls = tab.proto.fields.filter((e) => e.primaryKey && e.type.toUpperCase() == "INTEGER");
      if (ls.length == 1) {
        set(ls.first.name, id);
      }
    }
    return id;
  }

  int upsert({List<TableColumn>? columns, List<String>? names}) {
    EnumTable tab = mtable();
    List<FieldValue> ls = [];
    if (columns != null && columns.isNotEmpty) {
      for (TableColumn f in columns) {
        ls.add(tab.proto.find(f.nameColumn)! >> get(f));
      }
    } else if (names != null && names.isNotEmpty) {
      for (String f in names) {
        ls.add(tab.proto.find(f)! >> get(f));
      }
    } else {
      for (FieldProto f in tab.proto.fields) {
        ls.add(f >> get(f));
      }
    }

    if (ls.isEmpty) return 0;
    int id = tab.upsert(ls);
    if (id > 0) {
      var ls = tab.proto.fields.filter((e) => e.primaryKey && e.type.toUpperCase() == "INTEGER");
      if (ls.length == 1) {
        set(ls.first.name, id);
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
    String k = key is TableColumn ? key.nameColumn : (key is FieldProto ? key.name : key.toString());
    var v = model[k];
    return _checkNum(v);
  }

  void set<T>(Object key, T? value) {
    String k = key is TableColumn ? key.nameColumn : (key is FieldProto ? key.name : key.toString());
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
