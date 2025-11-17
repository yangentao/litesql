part of 'sql.dart';

class EnumTable {
  LiteSQL lite;
  Type tableType;
  late TableProto proto;

  EnumTable({required this.lite, required this.tableType}) {
    var t = findTableByEnum(tableType);
    if (t == null) {
      errorSQL("Table info NOT found, type=$tableType");
    }
    proto = t;
  }

  static EnumTable of(Type type) => From(type);

  String get tableName => proto.name;

  List<FieldProto> primaryKeys() => proto.fields.filter((e) => e.primaryKey);

  T? oneByKey<T>(
    T Function(MapSQL) creator, {
    required dynamic key,
    List<dynamic>? columns,
    String? groupBy,
    String? having,
    String? window,
    String? orderBy,
    List<String>? orders,
  }) {
    return one<T>(creator, columns: columns, where: keyEQ(key), groupBy: groupBy, having: having, window: window, orderBy: orderBy, orders: orders);
  }

  T? oneByKeys<T>(
    T Function(MapSQL) creator, {
    required List<dynamic> keys,
    List<dynamic>? columns,
    String? groupBy,
    String? having,
    String? window,
    String? orderBy,
    List<String>? orders,
  }) {
    return one<T>(creator, columns: columns, where: keysEQ(keys), groupBy: groupBy, having: having, window: window, orderBy: orderBy, orders: orders);
  }

  V? oneValue<E extends TableColumn<E>, V>(TableColumn<E> column, {Where? where, String? groupBy, String? having, String? window, String? orderBy, List<String>? orders}) {
    return this.query(columns: [column], where: where, groupBy: groupBy, having: having, window: window, orderBy: orderBy, orders: orders, limit: 1).firstValue;
  }

  T? one<T>(
    T Function(MapSQL) creator, {
    List<dynamic>? columns,
    Where? where,
    List<Where>? wheres,
    String? groupBy,
    String? having,
    String? window,
    String? orderBy,
    List<String>? orders,
  }) {
    return list<T>(
      creator,
      columns: columns,
      where: where,
      wheres: wheres,
      groupBy: groupBy,
      having: having,
      window: window,
      orderBy: orderBy,
      orders: orders,
      limit: 1,
    ).firstOrNull;
  }

  List<T> listColumn<E extends TableColumn<E>, T>(
    TableColumn<E> column, {
    Where? where,
    List<Where>? wheres,
    String? groupBy,
    String? having,
    String? window,
    String? orderBy,
    List<String>? orders,
    int? limit,
    int? offset,
  }) {
    return query(
      columns: [column],
      where: where,
      wheres: wheres,
      groupBy: groupBy,
      having: having,
      window: window,
      orderBy: orderBy,
      orders: orders,
      limit: limit,
      offset: offset,
    ).listValues();
  }

  List<T> list<T>(
    T Function(MapSQL) creator, {
    List<dynamic>? columns,
    Where? where,
    List<Where>? wheres,
    String? groupBy,
    String? having,
    String? window,
    String? orderBy,
    List<String>? orders,
    int? limit,
    int? offset,
  }) {
    return this
        .query(
          columns: columns,
          where: where,
          wheres: wheres,
          groupBy: groupBy,
          having: having,
          window: window,
          orderBy: orderBy,
          orders: orders,
          limit: limit,
          offset: offset,
        )
        .listModel(creator);
  }

  QueryResult query({
    List<dynamic>? columns,
    Where? where,
    List<Where>? wheres,
    String? groupBy,
    String? having,
    String? window,
    String? orderBy,
    List<String>? orders,
    int? limit,
    int? offset,
  }) {
    List<Where> wList = [where, ...?wheres].nonNullList;
    var w = AND_ALL(wList).result();
    return lite
        .query(
          columns?.mapList((e) => e is TableColumn ? e.nameSQL : e.toString()),
          from: tableName,
          where: w.clause,
          groupBy: groupBy,
          having: having,
          window: window,
          orderBy: orderBy,
          orders: orders,
          limit: limit,
          offset: offset,
          args: w.args,
        )
        .result;
  }

  Where keyEQ(dynamic keyValue) {
    var keyList = proto.fields.filter((e) => e.primaryKey);
    if (keyList.length != 1) errorSQL("Primary Key count MULST is ONE");
    return keyList.first.EQ(keyValue);
  }

  Where keysEQ(List<dynamic> keyValues) {
    var keyList = proto.fields.filter((e) => e.primaryKey);
    if (keyList.isEmpty) errorSQL("No Primary Key defined");
    if (keyList.length > keyValues.length) errorSQL("Primary Key Great than key value length");
    List<Where> ws = keyList.mapIndex((n, e) => e.EQ(keyValues[n]));
    return AND_ALL(ws);
  }

  int delete(Where where, {Returning? returning}) {
    var w = where.result();
    return lite.delete(tableName, where: w.clause, args: w.args, returning: returning);
  }

  /// From(Configs).upsert([Configs.name >> name, Configs.sValue >> value]);
  int update(List<FieldValue> values, {Where? where, Returning? returning}) {
    var w = where?.result();
    return lite.update(proto.name, values.mapList((e) => LabelValue(e.field.nameSQL, e.value)), where: w?.clause, args: w?.args, returning: returning);
  }

  List<int> upsertAll(List<List<FieldValue>> rows, {Returning? returning}) {
    if (rows.isEmpty) return [];
    return lite.upsertRows(proto.name, rows, returning: returning);
  }

  int upsert(List<FieldValue> row, {Returning? returning}) {
    return lite.upsertFields(tableName, row, returning: returning);
  }

  List<int> insertAll(List<List<FieldValue>> rows, {InsertOption? conflict, Returning? returning}) {
    if (rows.isEmpty) return [];
    return lite.insertRows(proto.name, rows.mapList((r) => r.mapList((e) => LabelValue(e.field.name, e.value))), conflict: conflict, returning: returning);
  }

  int insert(List<FieldValue> row, {InsertOption? conflict, Returning? returning}) {
    return lite.insert(proto.name, row.mapList((e) => LabelValue(e.field.name, e.value)), conflict: conflict, returning: returning);
  }

  int save(dynamic item) {
    if (item == null) return 0;
    if (_canSave(item)) {
      return upsert(proto.fields.mapList((e) => e >> e.get(item)));
    }
    errorSQL("Unkonwn object to save: $item");
  }

  List<int> saveAll(List<dynamic> items) {
    if (items.isEmpty) return [];
    var ls = items.filter((item) => _canSave(item));
    return upsertAll(ls.mapList((item) => proto.fields.mapList((e) => e >> e.get(item))));
  }

  void dump() {
    lite.dumpTable(tableName);
  }
}

extension LiteSQLEnum on LiteSQL {
  /// liteSQL.migrateEnumTable(Person.values)
  void migrateEnumTable<T extends TableColumn<T>>(List<T> fields) {
    MigrateEnumTable(this, fields);
  }

  /// liteSQL.from(Person)
  EnumTable from(Type table) {
    return EnumTable(lite: this, tableType: table);
  }
}

extension ETableFieldValueEx<T extends TableColumn<T>> on TableColumn<T> {
  FieldValue operator >>(dynamic value) {
    return FieldValue(this.proto, value);
  }
}

extension ResultSetExtResult on ResultSet {
  QueryResult get result => QueryResult(this);
}

class QueryResult with ListMixin<MapSQL> {
  ResultSet resultSet;

  QueryResult(this.resultSet);

  int get columnCount => resultSet.columnNames.length;

  List<String> get columnNames => resultSet.columnNames;

  Object? valueAt(int row, int col) => resultSet.rows[row][col];

  Object? valueNamed(int row, String name) => resultSet[row][name];

  MapSQL rowAt(int index) => resultSet[index].mapSQL;

  MapSQL? get firstRow => resultSet.firstOrNull?.mapSQL;

  List<MapSQL> get listRows => resultSet.mapList((e) => e.mapSQL);

  dynamic get firstValue => resultSet.firstOrNull?.columnAt(0);

  List<T> listValues<T>() => resultSet.mapList((e) => e.columnAt(0));

  T modelAt<T>(int index, ModelCreator<T> creator) => resultSet.elementAt(index).let((e) => creator(e));

  T? firstModel<T>(ModelCreator<T> creator) => firstRow?.let((e) => creator(e));

  List<T> listModel<T>(ModelCreator<T> creator) => listRows.mapList((e) => creator(e));

  @override
  int get length => resultSet.length;

  @override
  MapSQL operator [](int index) {
    return rowAt(index);
  }

  @override
  void operator []=(int index, MapSQL value) {
    errorSQL("QueryResult is inmutable");
  }

  @override
  set length(int newLength) {
    errorSQL("QueryResult is inmutable");
  }

  void dump() {
    if (this.isEmpty) {
      logSQL.d("[empty]");
      return;
    }
    for (MapSQL r in this) {
      logSQL.d(json.encode(r));
    }
  }
}
