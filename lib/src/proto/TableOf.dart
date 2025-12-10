part of '../sql.dart';

// 顺序必须M在前, 这样可以推导出E的类型
class TableOf<M extends TableModel<E>, E> {
  final M Function(AnyMap) creator;
  final TableProto proto;
  late final List<TableColumn> primaryKeys = proto.columns.filter((e) => e.proto.primaryKey);

  /// require dart 3.7
  TableOf(this.creator) : proto = TableProto.of(E);

  LiteSQL get lite => proto.lite;

  String get tableName => proto.name;

  V? oneValue<V>({required Object column, Where? where, Object? groupBy, Object? having, Object? window, Object? orderBy}) {
    return this.query(columns: [column], where: where, groupBy: groupBy, having: having, window: window, orderBy: orderBy, limit: 1).firstValue();
  }

  List<V> listColumn<V>({required Object column, Where? where, Object? groupBy, Object? having, Object? window, Object? orderBy, int? limit, int? offset}) {
    return query(columns: [column], where: where, groupBy: groupBy, having: having, window: window, orderBy: orderBy, limit: limit, offset: offset).listValues();
  }

  /// xx(key: 1, ...)
  /// xx(key: [1,name],...)
  /// support union primary key(s)
  M? oneBy({required Object key, Object? groupBy, Object? having, Object? window, Object? orderBy}) {
    return oneModel(where: _keyWhere(key), groupBy: groupBy, having: having, window: window, orderBy: orderBy);
  }

  M? oneModel({Where? where, Object? groupBy, Object? having, Object? window, Object? orderBy}) {
    return listModel(where: where, groupBy: groupBy, having: having, window: window, orderBy: orderBy, limit: 1).firstOrNull;
  }

  List<M> listModel({Where? where, Object? groupBy, Object? having, Object? window, Object? orderBy, int? limit, int? offset}) {
    return this.query(where: where, groupBy: groupBy, having: having, window: window, orderBy: orderBy, limit: limit, offset: offset).listModels(creator);
  }

  QueryResult query({List<Object>? columns, Where? where, Object? groupBy, Object? having, Object? window, Object? orderBy, int? limit, int? offset}) {
    return lite.query(columns ?? [], from: tableName, where: where, groupBy: groupBy, having: having, window: window, orderBy: orderBy, limit: limit, offset: offset);
  }

  QueryResult delete({required Where where, List<Object>? returning}) {
    return lite.delete(tableName, where: where, returning: returning);
  }

  /// xx(key: 1, ...)
  /// xx(key: [1,name],...)
  /// support union primary key(s)
  QueryResult deleteBy({required Object key, List<Object>? returning}) {
    return delete(where: _keyWhere(key), returning: returning);
  }

  QueryResult update({required List<ColumnValue> values, required Where where, List<Object>? returning}) {
    return lite.update(tableName, values: values, where: where, returning: returning);
  }

  /// xx(key: 1, ...)
  /// xx(key: [1,name],...)
  /// support union primary key(s)
  QueryResult updateBy({required Object key, required List<ColumnValue> values, List<Object>? returning}) {
    return lite.update(tableName, values: values, where: _keyWhere(key), returning: returning);
  }

  QueryResult upsert({required List<ColumnValue> values, List<Object>? returning}) {
    return lite.upsert(tableName, values: values, constraints: primaryKeys, returning: returning);
  }

  QueryResult insert({required List<ColumnValue> values, InsertOption? conflict, List<Object>? returning}) {
    if (values.isEmpty) return emptyResult;
    return lite.insert(tableName, values: values, conflict: conflict, returning: returning);
  }

  List<QueryResult> insertAll({required List<List<ColumnValue>> rows, InsertOption? conflict, List<Object>? returning}) {
    if (rows.isEmpty) return [];
    return lite.insertAll(tableName, rows: rows, conflict: conflict, returning: returning);
  }

  QueryResult save(M? item, {List<Object>? returning = ALL_COLUMNS}) {
    if (item == null) return emptyResult;
    QueryResult r = upsert(values: proto.columns.mapList((e) => e >> e.get(item)), returning: returning);
    if (r.isNotEmpty) {
      item.model.addAll(r.firstMap()!);
    }
    return r;
  }

  List<QueryResult> saveAll(List<M> items, {List<Object>? returning = ALL_COLUMNS}) {
    if (items.isEmpty) return [];
    List<QueryResult> idList = [];
    for (M item in items) {
      idList << save(item, returning: returning);
    }
    return idList;
  }

  Where _keyWhere(Object value) => _keyEQ(value: value, keys: primaryKeys);

  void dump() {
    lite.dumpTable(tableName);
  }
}

Where _keyEQ({required Object value, required List<TableColumn> keys}) {
  if (value is Where) return value;
  if (keys.isEmpty) errorSQL("No Primary Key defined");
  if (value is List<dynamic>) {
    List<dynamic> values = value.nonNullList;
    if (keys.length != values.length) errorSQL("Primary Keys has different size of given values");
    return keys.mapIndex((n, e) => e.EQ(values[n])).and();
  } else {
    if (keys.length != 1) errorSQL("Primary Key count MUST be one");
    return keys.first.EQ(value);
  }
}
