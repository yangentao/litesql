part of 'sql.dart';

Map<Type, TableProto> _enumTypeMap = {};

TableProto? findTableByEnum(Type type) => _enumTypeMap[type];

EnumTable From(Type type) {
  return tableOfType(type);
}

EnumTable FromTable(Type type) {
  return tableOfType(type);
}

EnumTable tableOfType(Type type) {
  var info = findTableByEnum(type)!;
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
