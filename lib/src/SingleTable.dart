part of 'sql.dart';

@Deprecated("Use TableOf instead. for example: final table = TableOf(Person.new)")
class SingleTable {
  final LiteSQL lite;
  final TableProto proto;
  late final List<TableColumn> primaryKeys = proto.columns.filter((e) => e.proto.primaryKey);

  SingleTable._(this.proto, {LiteSQL? lite}) : lite = lite ?? proto.liteSQL;

  /// SingleTable(Person)
  SingleTable(Type type, {LiteSQL? lite}) : this._(TableProto.of(type), lite: lite);

  String get tableName => proto.name;

  T? oneByKey<T>({required T Function(AnyMap) creator, required Object key, List<Object>? columns, Object? groupBy, Object? having, Object? window, Object? orderBy}) {
    return oneModel<T>(creator: creator, columns: columns, where: keyEQ(key), groupBy: groupBy, having: having, window: window, orderBy: orderBy);
  }

  T? oneByKeys<T>({
    required T Function(AnyMap) creator,
    required List<Object> keys,
    List<Object>? columns,
    Object? groupBy,
    Object? having,
    Object? window,
    Object? orderBy,
  }) {
    return oneModel<T>(creator: creator, columns: columns, where: keysEQ(keys), groupBy: groupBy, having: having, window: window, orderBy: orderBy);
  }

  V? oneValue<V>(Object column, {Where? where, Object? groupBy, Object? having, Object? window, Object? orderBy}) {
    return this.query(columns: [column], where: where, groupBy: groupBy, having: having, window: window, orderBy: orderBy, limit: 1).firstValue();
  }

  List<T> listColumn<T>(Object column, {Where? where, Object? groupBy, Object? having, Object? window, Object? orderBy, int? limit, int? offset}) {
    return query(columns: [column], where: where, groupBy: groupBy, having: having, window: window, orderBy: orderBy, limit: limit, offset: offset).listValues();
  }

  T? oneModel<T>({required T Function(AnyMap) creator, List<Object>? columns, Where? where, Object? groupBy, Object? having, Object? window, Object? orderBy}) {
    return listModel<T>(creator: creator, columns: columns, where: where, groupBy: groupBy, having: having, window: window, orderBy: orderBy, limit: 1).firstOrNull;
  }

  List<T> listModel<T>({
    required T Function(AnyMap) creator,
    List<Object>? columns,
    Where? where,
    Object? groupBy,
    Object? having,
    Object? window,
    Object? orderBy,
    int? limit,
    int? offset,
  }) {
    return this
        .query(columns: columns, where: where, groupBy: groupBy, having: having, window: window, orderBy: orderBy, limit: limit, offset: offset)
        .listModels(creator);
  }

  ResultSet query({List<Object>? columns, Where? where, Object? groupBy, Object? having, Object? window, Object? orderBy, int? limit, int? offset}) {
    return lite.query(columns ?? [], from: tableName, where: where, groupBy: groupBy, having: having, window: window, orderBy: orderBy, limit: limit, offset: offset);
  }

  Where keyEQ(Object keyValue) {
    if (keyValue is Where) return keyValue;
    var keyList = primaryKeys;
    if (keyList.length != 1) errorSQL("Primary Key count MUST be one");
    return keyList.first.EQ(keyValue);
  }

  Where keysEQ(List<Object> keyValues) {
    var keyList = primaryKeys;
    if (keyList.isEmpty) errorSQL("No Primary Key defined");
    if (keyList.length != keyValues.length) errorSQL("Primary Keys has different size of given values");
    List<Where> ws = keyList.mapIndex((n, e) => e.EQ(keyValues[n]));
    return AND_ALL(ws);
  }

  int deleteByKey(Object key, {Returning? returning}) {
    return delete(keyEQ(key), returning: returning);
  }

  int delete(Where where, {Returning? returning}) {
    return lite.delete(tableName, where: where, returning: returning);
  }

  int update({required List<ColumnValue> values, required Where where, Returning? returning}) {
    return lite.update(tableName, values: values, where: where, returning: returning);
  }

  int upsert(List<ColumnValue> row, {Returning? returning}) {
    return lite.upsert(tableName, values: row, constraints: primaryKeys, returning: returning);
  }

  List<int> insertAll(List<List<ColumnValue>> rows, {InsertOption? conflict, Returning? returning}) {
    if (rows.isEmpty) return [];
    return lite.insertAll(tableName, rows: rows, conflict: conflict, returning: returning);
  }

  int insert(List<ColumnValue> values, {InsertOption? conflict, Returning? returning}) {
    if (values.isEmpty) return 0;
    return lite.insert(tableName, values: values, conflict: conflict, returning: returning);
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
    var rows = ls.mapList((item) => proto.columns.mapList((e) => e >> e.get(item)));
    return lite.upsertAll(tableName, rows: rows, constraints: primaryKeys);
  }

  void dump() {
    lite.dumpTable(tableName);
  }
}
