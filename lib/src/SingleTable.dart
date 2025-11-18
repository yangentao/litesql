part of 'sql.dart';

class SingleTable {
  LiteSQL lite;
  TableProto proto;

  SingleTable._(this.proto, {LiteSQL? lite}) : lite = lite ?? proto.liteSQL;

  /// SingleTable(Person)
  SingleTable(Type type, {LiteSQL? lite}) : this._(TableProto.of(type), lite: lite);

  String get tableName => proto.name;

  List<TableColumn> primaryKeys() => proto.columns.filter((e) => e.proto.primaryKey);

  T? oneByKey<T>(
    T Function(AnyMap) creator, {
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
    T Function(AnyMap) creator, {
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

  V? oneValue<E extends TableColumn<E>, V>(
    TableColumn<E> column, {
    Where? where,
    String? groupBy,
    String? having,
    String? window,
    String? orderBy,
    List<String>? orders,
  }) {
    return this.query(columns: [column], where: where, groupBy: groupBy, having: having, window: window, orderBy: orderBy, orders: orders, limit: 1).firstValue();
  }

  T? one<T>(
    T Function(AnyMap) creator, {
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
    ).allValues();
  }

  List<T> list<T>(
    T Function(AnyMap) creator, {
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
        .allModels(creator);
  }

  ResultSet query({
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
    var w = AND_ALL(wList);
    return lite.query(
      columns?.mapList((e) => e is TableColumn ? e.nameSQL : e.toString()),
      from: tableName,
      where: w.sql,
      groupBy: groupBy,
      having: having,
      window: window,
      orderBy: orderBy,
      orders: orders,
      limit: limit,
      offset: offset,
      args: w.args,
    );
  }

  Where keyEQ(dynamic keyValue) {
    var keyList = proto.columns.filter((e) => e.proto.primaryKey);
    if (keyList.length != 1) errorSQL("Primary Key count MULST is ONE");
    return keyList.first.EQ(keyValue);
  }

  Where keysEQ(List<dynamic> keyValues) {
    var keyList = proto.columns.filter((e) => e.proto.primaryKey);
    if (keyList.isEmpty) errorSQL("No Primary Key defined");
    if (keyList.length > keyValues.length) errorSQL("Primary Key Great than key value length");
    List<Where> ws = keyList.mapIndex((n, e) => e.EQ(keyValues[n]));
    return AND_ALL(ws);
  }

  int delete(Where where, {Returning? returning}) {
    var w = where;
    return lite.delete(tableName, where: w.sql, args: w.args, returning: returning);
  }

  int updateBy<T extends TableColumn<T>>(List<(TableColumn<T>, dynamic value)> row, {Where? where, Returning? returning}) {
    return update(row.mapList((e) => e.$1 >> e.$2), where: where, returning: returning);
  }

  /// From(Configs).upsert([Configs.name >> name, Configs.sValue >> value]);
  int update(List<ColumnValue> values, {Where? where, Returning? returning}) {
    return lite.update(proto.name, values.mapList((e) => LabelValue(e.column.columnName, e.value)), where: where?.sql, args: where?.args, returning: returning);
  }

  List<int> upsertAll(List<List<ColumnValue>> rows, {Returning? returning}) {
    if (rows.isEmpty) return [];
    return lite.upsertRows(proto.name, rows, returning: returning);
  }

  int upsert(List<ColumnValue> row, {Returning? returning}) {
    return lite.upsertFields(tableName, row, returning: returning);
  }

  int upsertBy<T extends TableColumn<T>>(List<(TableColumn<T>, dynamic value)> row, {Returning? returning}) {
    return lite.upsertFields(tableName, row.mapList((e) => e.$1 >> e.$2), returning: returning);
  }

  List<int> insertAll(List<List<ColumnValue>> rows, {InsertOption? conflict, Returning? returning}) {
    if (rows.isEmpty) return [];
    return lite.insertRows(proto.name, rows.mapList((r) => r.mapList((e) => LabelValue(e.column.columnName, e.value))), conflict: conflict, returning: returning);
  }

  int insert(List<ColumnValue> row, {InsertOption? conflict, Returning? returning}) {
    return lite.insert(proto.name, row.mapList((e) => LabelValue(e.column.columnName, e.value)), conflict: conflict, returning: returning);
  }

  int save(dynamic item) {
    if (item == null) return 0;
    if (_canSave(item)) {
      return upsert(proto.columns.mapList((e) => e >> e.get(item)));
    }
    errorSQL("Unkonwn object to save: $item");
  }

  List<int> saveAll(List<dynamic> items) {
    if (items.isEmpty) return [];
    var ls = items.filter((item) => _canSave(item));
    return upsertAll(ls.mapList((item) => proto.columns.mapList((e) => e >> e.get(item))));
  }

  void dump() {
    lite.dumpTable(tableName);
  }
}
