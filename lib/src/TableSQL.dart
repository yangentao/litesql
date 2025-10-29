part of 'sql.dart';

class TableSQL {
  final String name;
  final List<FieldSQL> fields;
  final String nameSQL;

  TableSQL(this.name, this.fields) : nameSQL = name.escapeSQL {
    for (var e in fields) {
      e.table = this;
    }
  }

  String JOIN(TableSQL other, {required String on}) {
    return "$nameSQL JOIN ${other.nameSQL} ON $on";
  }

  String LEFT_JOIN(TableSQL other, {required String on}) {
    return "$nameSQL LEFT JOIN ${other.nameSQL} ON $on";
  }

  String RIGHT_JOIN(TableSQL other, {required String on}) {
    return "$nameSQL RIGHT JOIN ${other.nameSQL} ON $on";
  }

  String FULL_JOIN(TableSQL other, {required String on}) {
    return "$nameSQL FULL JOIN ${other.nameSQL} ON $on";
  }
}

extension FieldSQLJoinOnExt on FieldSQL {}

class SingleTable {
  TableSQL table;
  LiteSQL lite;

  SingleTable({required this.lite, required this.table});

  Where keyEQ(dynamic keyValue) {
    var keyList = table.fields.filter((e) => e.primaryKey);
    if (keyList.length != 1) throw HareException("Primary Key count MULST is ONE");
    return keyList.first.EQ(keyValue);
  }

  Where keysEQ(List<dynamic> keyValues) {
    var keyList = table.fields.filter((e) => e.primaryKey);
    if (keyList.isEmpty) throw HareException("No Primary Key defined");
    if (keyList.length > keyValues.length) throw HareException("Primary Key Great than key value length");
    List<Where> ws = keyList.mapIndex((n, e) => e.EQ(keyValues[n]));
    return AND_ALL(ws);
  }

  dynamic oneValue(FieldSQL column, {Where? where, String? groupBy, String? having, String? window, String? order, List<String>? orderBy}) {
    var w = where?.result();
    return lite
        .select(
          [column.name],
          from: table.name,
          where: w?.clause,
          groupBy: groupBy,
          having: having,
          window: window,
          order: order,
          orderBy: orderBy,
          limit: 1,
          args: w?.args,
        )
        .firstRowFirstColumn;
  }

  T? oneByKey<T>(
    T Function(MapSQL) creator, {
    required dynamic key,
    List<String>? selections,
    List<FieldSQL>? columns,
    String? groupBy,
    String? having,
    String? window,
    String? order,
    List<String>? orderBy,
  }) {
    return one<T>(creator, selections: selections, columns: columns, where: keyEQ(key), groupBy: groupBy, having: having, window: window, order: order, orderBy: orderBy);
  }

  T? oneByKeys<T>(
    T Function(MapSQL) creator, {
    required List<dynamic> keys,
    List<String>? selections,
    List<FieldSQL>? columns,
    String? groupBy,
    String? having,
    String? window,
    String? order,
    List<String>? orderBy,
  }) {
    return one<T>(
      creator,
      selections: selections,
      columns: columns,
      where: keysEQ(keys),
      groupBy: groupBy,
      having: having,
      window: window,
      order: order,
      orderBy: orderBy,
    );
  }

  T? one<T>(
    T Function(MapSQL) creator, {
    List<String>? selections,
    List<FieldSQL>? columns,
    Where? where,
    List<Where>? wheres,
    String? groupBy,
    String? having,
    String? window,
    String? order,
    List<String>? orderBy,
  }) {
    return list<T>(
      creator,
      selections: selections,
      columns: columns,
      where: where,
      wheres: wheres,
      groupBy: groupBy,
      having: having,
      window: window,
      order: order,
      orderBy: orderBy,
      limit: 1,
    ).firstOrNull;
  }

  List<T> listColumn<T>(
    String column, {
    Where? where,
    List<Where>? wheres,
    String? groupBy,
    String? having,
    String? window,
    String? order,
    List<String>? orderBy,
    int? limit,
    int? offset,
  }) {
    ResultSet rs = query(
      selections: [column],
      where: where,
      wheres: wheres,
      groupBy: groupBy,
      having: having,
      window: window,
      order: order,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    return rs.mapList((e) => e.firstColumn);
  }

  List<T> list<T>(
    T Function(MapSQL) creator, {
    List<String>? selections,
    List<FieldSQL>? columns,
    Where? where,
    List<Where>? wheres,
    String? groupBy,
    String? having,
    String? window,
    String? order,
    List<String>? orderBy,
    int? limit,
    int? offset,
  }) {
    ResultSet rs = query(
      selections: selections,
      columns: columns,
      where: where,
      wheres: wheres,
      groupBy: groupBy,
      having: having,
      window: window,
      order: order,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    return rs.mapList((e) => creator(e.mapSQL));
  }

  ResultSet query({
    List<String>? selections,
    List<FieldSQL>? columns,
    Where? where,
    List<Where>? wheres,
    String? groupBy,
    String? having,
    String? window,
    String? order,
    List<String>? orderBy,
    int? limit,
    int? offset,
  }) {
    List<Where> wList = [where, ...?wheres].nonNullList;
    var w = AND_ALL(wList).result();
    List<String> selList = [...?selections, ...?columns?.mapList((e) => e.nameSQL)];
    return lite.select(
      selList,
      from: table.name,
      where: w.clause,
      groupBy: groupBy,
      having: having,
      window: window,
      order: order,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
      args: w.args,
    );
  }

  int delete(Where where) {
    var w = where.result();
    return lite.delete(table.nameSQL, where: w.clause, args: w.args);
  }

  int update(List<FieldValue> values, {Where? where}) {
    var w = where?.result();
    return lite.update(table.name, values.mapList((e) => LabelValue(e.field.nameSQL, e.value)), where: w?.clause, args: w?.args);
  }

  List<int> upsertAll(List<List<FieldValue>> rows) {
    return lite.upsertRows(table.name, rows);
  }

  int upsert(List<FieldValue> row) {
    return lite.upsert(table.name, row);
  }

  int insertAll(List<List<FieldValue>> rows) {
    return lite.insertRows(table.name, rows.mapList((r) => r.mapList((e) => LabelValue(e.field.name, e.value))));
  }

  int insert(List<FieldValue> row) {
    return lite.insertRow(table.name, row.mapList((e) => LabelValue(e.field.name, e.value)));
  }

  /// JsonModel , JsonValue, JsonMap
  int save(dynamic item) {
    if (item == null) return 0;
    if (item is JsonMap || item is JsonValue || item is JsonModel) {
      return upsert(table.fields.mapList((e) => e >> e.get(item)));
    }
    throw HareException("Unkonwn object to save: $item");
  }

  /// JsonModel , JsonValue, JsonMap
  List<int> saveAll(JsonList items) {
    var ls = items.filter((item) => item is JsonMap || item is JsonValue || item is JsonModel);
    return upsertAll(ls.mapList((item) => table.fields.mapList((e) => e >> e.get(item))));
  }

  void migrate() {
    lite.migrate(table);
  }

  void dump() {
    lite.dumpTable(table.name);
  }
}
