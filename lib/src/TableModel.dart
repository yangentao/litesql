part of 'sql.dart';

class TableModel<E> {
  AnyMap model;
  Type tableType = E;
  final Set<String> _modifiedKeys = {};

  TableModel(this.model);

  EnumTable mtable() {
    if (E == Object) errorSQL("TableModel<T>, generic type parameter MUST be set");
    return EnumTable.of(E);
  }

  void clearModifyFlag() {
    _modifiedKeys.clear();
  }

  /// delete by key
  int delete() {
    EnumTable tab = mtable();
    List<ColumnProto> pks = tab.primaryKeys();
    if (pks.isEmpty) errorSQL("NO primary key defined.");
    List<Where> wherePks = [];
    for (ColumnProto f in pks) {
      dynamic v = get(f.name);
      if (v == null) errorSQL("Primary key is null: ${f.name}");
      wherePks.add(f.EQ(v));
    }
    if (wherePks.isEmpty) errorSQL("NO primary key condition(s).");
    return tab.delete(wherePks.and());
  }

  /// MPerson p = From(Person).oneByKey(MPerson.new , key: 1)!
  /// p.update((){
  ///   p.name = "new name";
  /// });
  /// ONLY update columns changed in callback.
  int update(VoidCallback callback) {
    EnumTable tab = mtable();
    List<ColumnProto> pks = tab.primaryKeys();
    if (pks.isEmpty) errorSQL("NO primary key defined.");
    _modifiedKeys.clear();
    callback();
    if (_modifiedKeys.isEmpty) return 0;
    List<Where> wherePks = [];
    for (ColumnProto f in pks) {
      dynamic v = get(f.name);
      if (v == null) errorSQL("Primary key is null: ${f.name}");
      wherePks.add(f.EQ(v));
    }

    List<FieldValue> values = [];
    for (String k in _modifiedKeys) {
      ColumnProto f = tab.proto.fields.firstWhere((e) => e.name == k);
      if (!f.primaryKey) {
        values.add(f >> get(k));
      }
    }
    _modifiedKeys.clear();
    if (values.isEmpty) return 0;
    Returning ret = Returning.ALL;
    int n = tab.update(values, where: wherePks.and(), returning: ret);
    if (n > 0) {
      this.model.addAll(ret.firstRow);
    }

    return n;
  }

  int updateBy({List<TableColumn>? columns, List<String>? names, List<TableColumn>? excludeColumns, List<String>? excludeNames}) {
    EnumTable tab = mtable();

    List<ColumnProto> pks = tab.primaryKeys();
    if (pks.isEmpty) errorSQL("NO primary key defined.");
    List<Where> wherePks = [];
    for (ColumnProto f in pks) {
      dynamic v = get(f.name);
      if (v == null) errorSQL("Primary key is null: ${f.name}");
      wherePks.add(f.EQ(v));
    }
    List<FieldValue> values = fieldValues(columns: columns, names: names, excludeColumns: excludeColumns, excludeNames: excludeNames);
    values.removeWhere((e) => e.field.primaryKey);
    if (values.isEmpty) return 0;
    Returning ret = Returning.ALL;
    int n = tab.update(values, where: wherePks.and(), returning: ret);
    if (n > 0) {
      this.model.addAll(ret.firstRow);
    }
    return n;
  }

  int insert({InsertOption? conflict, List<TableColumn>? columns, List<String>? names, List<TableColumn>? excludeColumns, List<String>? excludeNames}) {
    EnumTable tab = mtable();
    List<FieldValue> ls = fieldValues(columns: columns, names: names, excludeColumns: excludeColumns, excludeNames: excludeNames);
    if (ls.isEmpty) return 0;
    Returning ret = Returning.ALL;
    int id = tab.insert(ls, conflict: conflict, returning: ret);
    if (tab.lite.updatedRows > 0) {
      this.model.addAll(ret.firstRow);
    }
    // if (id > 0) {
    //   var ls = tab.proto.fields.filter((e) => e.primaryKey && e.type.toUpperCase() == "INTEGER");
    //   if (ls.length == 1) {
    //     set(ls.first.name, id);
    //   }
    // }
    return id;
  }

  int upsert({List<TableColumn>? columns, List<String>? names, List<TableColumn>? excludeColumns, List<String>? excludeNames}) {
    EnumTable tab = mtable();
    List<FieldValue> ls = fieldValues(columns: columns, names: names, excludeColumns: excludeColumns, excludeNames: excludeNames);
    if (ls.isEmpty) return 0;
    Returning ret = Returning.ALL;
    int id = tab.upsert(ls, returning: ret);
    if (tab.lite.updatedRows > 0) {
      this.model.addAll(ret.firstRow);
    }
    // if (id > 0) {
    //   var ls = tab.proto.fields.filter((e) => e.primaryKey && e.type.toUpperCase() == "INTEGER");
    //   if (ls.length == 1) {
    //     set(ls.first.name, id);
    //   }
    // }
    _modifiedKeys.clear();
    return id;
  }

  List<FieldValue> fieldValues({List<TableColumn>? columns, List<String>? names, List<TableColumn>? excludeColumns, List<String>? excludeNames}) {
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
      for (ColumnProto f in tab.proto.fields) {
        ls.add(f >> get(f));
      }
    }
    if (excludeColumns != null && excludeColumns.isNotEmpty) {
      for (TableColumn c in excludeColumns) {
        ls.removeWhere((e) => e.field.name == c.nameColumn);
      }
    }
    if (excludeNames != null && excludeNames.isNotEmpty) {
      for (String n in excludeNames) {
        ls.removeWhere((e) => e.field.name == n);
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
    String k = _nameOfKey(key);
    var v = model[k];
    return _checkNum(v);
  }

  void set<T>(Object key, T? value) {
    String k = _nameOfKey(key);
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

String _nameOfKey(Object key) {
  return switch (key) {
    TableColumn c => c.nameColumn,
    ColumnProto fp => fp.name,
    Symbol sy => sy.stringValue,
    _ => key.toString(),
  };
}
