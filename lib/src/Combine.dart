part of 'sql.dart';

class Combine<M extends TableModel<E>, E extends TableColumn<E>> {
  final TableProto proto = TableProto.of(E);
  late final LiteSQL lite = proto.liteSQL;
  late final List<TableColumn> primaryKeys = proto.columns.filter((e) => e.proto.primaryKey);
  M Function(AnyMap) creator;

  Combine(this.creator);

  String get tableName => proto.name;

  V? oneValue<V>({required Object column, Where? where, Object? groupBy, Object? having, Object? window, Object? orderBy}) {
    return this.query(columns: [column], where: where, groupBy: groupBy, having: having, window: window, orderBy: orderBy, limit: 1).firstValue();
  }

  List<V> listColumn<V>({required Object column, Where? where, Object? groupBy, Object? having, Object? window, Object? orderBy, int? limit, int? offset}) {
    return query(columns: [column], where: where, groupBy: groupBy, having: having, window: window, orderBy: orderBy, limit: limit, offset: offset).listValues();
  }

  M? oneByKey({required Object key, Object? groupBy, Object? having, Object? window, Object? orderBy}) {
    return oneModel(where: keyEQ(key), groupBy: groupBy, having: having, window: window, orderBy: orderBy);
  }

  M? oneByKeys({required List<Object> keys, Object? groupBy, Object? having, Object? window, Object? orderBy}) {
    return oneModel(where: keysEQ(keys), groupBy: groupBy, having: having, window: window, orderBy: orderBy);
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

  int deleteBy({required Object key, Returning? returning}) {
    return delete(where: keyEQ(key), returning: returning);
  }

  int delete({required Where where, Returning? returning}) {
    return lite.delete(tableName, where: where, returning: returning);
  }

  int update({required List<MapEntry<TableColumn<E>, dynamic>> values, required Where where, Returning? returning}) {
    return lite.update(tableName, values: values, where: where, returning: returning);
  }

  int upsert({required List<MapEntry<TableColumn, dynamic>> values, Returning? returning}) {
    return lite.upsert(tableName, values: values, constraints: primaryKeys, returning: returning);
  }

  int insert({required List<MapEntry<TableColumn<E>, dynamic>> values, InsertOption? conflict, Returning? returning}) {
    if (values.isEmpty) return 0;
    return lite.insert(tableName, values: values, conflict: conflict, returning: returning);
  }

  List<int> insertAll({required List<List<MapEntry<TableColumn<E>, dynamic>>> rows, InsertOption? conflict, Returning? returning}) {
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

  void dump() {
    lite.dumpTable(tableName);
  }
}
