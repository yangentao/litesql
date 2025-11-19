part of 'sql.dart';

class TableModel<E> {
  AnyMap model;
  Type tableType = E;
  final Set<String> _modifiedKeys = {};

  TableModel(this.model);

  SingleTable mtable() {
    if (E == Object) errorSQL("TableModel<T>, generic type parameter MUST be set");
    return SingleTable(E);
  }

  void clearModifyFlag() {
    _modifiedKeys.clear();
  }

  /// delete by key
  int delete() {
    SingleTable tab = mtable();
    List<TableColumn> pks = tab.primaryKeys;
    if (pks.isEmpty) errorSQL("NO primary key defined.");
    List<Where> wherePks = [];
    for (TableColumn f in pks) {
      dynamic v = get(f.columnName);
      if (v == null) errorSQL("Primary key is null: ${f.columnName}");
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
    SingleTable tab = mtable();
    List<TableColumn> pks = tab.primaryKeys;
    if (pks.isEmpty) errorSQL("NO primary key defined.");
    _modifiedKeys.clear();
    callback();
    if (_modifiedKeys.isEmpty) return 0;
    List<Where> wherePks = [];
    for (TableColumn f in pks) {
      dynamic v = get(f.columnName);
      if (v == null) errorSQL("Primary key is null: ${f.columnName}");
      wherePks.add(f.EQ(v));
    }

    List<ColumnValue> values = [];
    for (String k in _modifiedKeys) {
      TableColumn f = tab.proto.columns.firstWhere((e) => e.columnName == k);
      if (!f.proto.primaryKey) {
        values.add(f >> get(k));
      }
    }
    _modifiedKeys.clear();
    if (values.isEmpty) return 0;
    Returning ret = Returning.ALL;
    // int n = tab.update(values, where: wherePks.and(), returning: ret);
    // if (n > 0) {
    //   this.model.addAll(ret.firstRow);
    // }
    //
    // return n;
    return 0 ;
  }

  // int updateBy({List<TableColumn>? columns, List<String>? names, List<TableColumn>? excludeColumns, List<String>? excludeNames}) {
  //   SingleTable tab = mtable();
  //
  //   List<TableColumn> pks = tab.primaryKeys();
  //   if (pks.isEmpty) errorSQL("NO primary key defined.");
  //   List<Where> wherePks = [];
  //   for (TableColumn f in pks) {
  //     dynamic v = get(f.columnName);
  //     if (v == null) errorSQL("Primary key is null: ${f.columnName}");
  //     wherePks.add(f.EQ(v));
  //   }
  //   List<ColumnValue> values = fieldValues(columns: columns, names: names, excludeColumns: excludeColumns, excludeNames: excludeNames);
  //   values.removeWhere((e) => e.column.proto.primaryKey);
  //   if (values.isEmpty) return 0;
  //   Returning ret = Returning.ALL;
  //   int n = tab.update(values, where: wherePks.and(), returning: ret);
  //   if (n > 0) {
  //     this.model.addAll(ret.firstRow);
  //   }
  //   return n;
  // }

  // int insert({InsertOption? conflict, List<TableColumn>? columns, List<String>? names, List<TableColumn>? excludeColumns, List<String>? excludeNames}) {
  //   SingleTable tab = mtable();
  //   List<ColumnValue> ls = fieldValues(columns: columns, names: names, excludeColumns: excludeColumns, excludeNames: excludeNames);
  //   if (ls.isEmpty) return 0;
  //   Returning ret = Returning.ALL;
  //   int id = tab.insert(ls, conflict: conflict, returning: ret);
  //   if (tab.lite.updatedRows > 0) {
  //     this.model.addAll(ret.firstRow);
  //   }
  //   return id;
  // }

  // int upsert({List<TableColumn>? columns, List<String>? names, List<TableColumn>? excludeColumns, List<String>? excludeNames}) {
  //   SingleTable tab = mtable();
  //   List<KeyValue> ls = fieldValues(columns: columns, names: names, excludeColumns: excludeColumns, excludeNames: excludeNames);
  //   if (ls.isEmpty) return 0;
  //   Returning ret = Returning.ALL;
  //   int id = tab.upsert(ls, returning: ret);
  //   if (tab.lite.updatedRows > 0) {
  //     this.model.addAll(ret.firstRow);
  //   }
  //
  //   _modifiedKeys.clear();
  //   return id;
  // }

  List<ColumnValue> fieldValues({List<TableColumn>? columns, List<String>? names, List<TableColumn>? excludeColumns, List<String>? excludeNames}) {
    SingleTable tab = mtable();
    List<ColumnValue> ls = [];
    if (columns != null && columns.isNotEmpty) {
      for (TableColumn f in columns) {
        ls.add(tab.proto.find(f.columnName)! >> get(f));
      }
    } else if (names != null && names.isNotEmpty) {
      for (String f in names) {
        ls.add(tab.proto.find(f)! >> get(f));
      }
    } else {
      for (TableColumn f in tab.proto.columns) {
        ls.add(f >> get(f));
      }
    }
    if (excludeColumns != null && excludeColumns.isNotEmpty) {
      for (TableColumn c in excludeColumns) {
        ls.removeWhere((e) => e.keyName == c.columnName);
      }
    }
    if (excludeNames != null && excludeNames.isNotEmpty) {
      for (String n in excludeNames) {
        ls.removeWhere((e) => e.keyName == n);
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
    return _checkNum<T>(v);
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
    TableColumn c => c.columnName,
    Symbol sy => sy.stringValue,
    _ => key.toString(),
  };
}
