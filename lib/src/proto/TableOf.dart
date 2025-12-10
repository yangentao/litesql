part of '../sql.dart';

// 顺序必须M在前, 这样可以推导出E的类型
class TableOf<M extends TableModel<E>, E extends TableColumn> {
  final M Function(AnyMap) creator;
  late final TableProto<E> proto = TableProto<E>();
  late final LiteSQL lite = proto.liteSQL;
  late final List<TableColumn> primaryKeys = proto.columns.filter((e) => e.proto.primaryKey);

  TableOf(this.creator);

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

  ResultSet query({List<Object>? columns, Where? where, Object? groupBy, Object? having, Object? window, Object? orderBy, int? limit, int? offset}) {
    return lite.query(columns ?? [], from: tableName, where: where, groupBy: groupBy, having: having, window: window, orderBy: orderBy, limit: limit, offset: offset);
  }

  int delete({required Where where, Returning? returning}) {
    return lite.delete(tableName, where: where, returning: returning);
  }

  /// xx(key: 1, ...)
  /// xx(key: [1,name],...)
  /// support union primary key(s)
  int deleteBy({required Object key, Returning? returning}) {
    return delete(where: _keyWhere(key), returning: returning);
  }

  int update({required List<ColumnValue> values, required Where where, Returning? returning}) {
    return lite.update(tableName, values: values, where: where, returning: returning);
  }

  /// xx(key: 1, ...)
  /// xx(key: [1,name],...)
  /// support union primary key(s)
  int updateBy({required Object key, required List<ColumnValue> values, Returning? returning}) {
    return lite.update(tableName, values: values, where: _keyWhere(key), returning: returning);
  }

  int upsert({required List<ColumnValue> values, Returning? returning}) {
    return lite.upsert(tableName, values: values, constraints: primaryKeys, returning: returning);
  }

  int insert({required List<ColumnValue> values, InsertOption? conflict, Returning? returning}) {
    if (values.isEmpty) return 0;
    return lite.insert(tableName, values: values, conflict: conflict, returning: returning);
  }

  List<int> insertAll({required List<List<ColumnValue>> rows, InsertOption? conflict, Returning? returning}) {
    if (rows.isEmpty) return [];
    return lite.insertAll(tableName, rows: rows, conflict: conflict, returning: returning);
  }

  int save(M? item, {bool returning = true}) {
    if (item == null) return 0;
    if (returning) {
      Returning r = Returning.ALL;
      int n = upsert(values: proto.columns.mapList((e) => e >> e.get(item)), returning: r);
      if (r.hasReturn) {
        item.model.addAll(r.firstRow);
      }
      return n;
    } else {
      return upsert(values: proto.columns.mapList((e) => e >> e.get(item)));
    }
  }

  List<int> saveAll(List<M> items, {bool returning = true}) {
    if (items.isEmpty) return [];
    List<int> idList = [];
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
