part of 'sql.dart';

Map<Type, TableProto> _enumTypeMap = {};

TableProto _requireTableProto(Type type) {
  TableProto? p = _enumTypeMap[type];
  if (p == null) {
    errorSQL("NO table proto of $type  found, migrate it first. ");
  }
  return p;
}

EnumTable From(Type type) {
  return _tableOfType(type);
}

EnumTable FromTable(Type type) {
  return _tableOfType(type);
}

EnumTable _tableOfType(Type type) {
  var info = _requireTableProto(type);
  return info.liteSQL!.from(type);
}

void MigrateEnumTable<T extends TableColumn<T>>(LiteSQL lite, List<T> fields) {
  assert(fields.isNotEmpty);
  T first = fields.first;
  if (_enumTypeMap.containsKey(first.tableType)) return;

  List<FieldProto> fieldList = [];
  for (T item in fields) {
    fieldList.add(item.proto);
  }

  TableProto tab = TableProto(first.tableName, fieldList);
  _enumTypeMap[first.tableType] = tab;
  lite.migrate(tab);
  tab.liteSQL = lite;
}
