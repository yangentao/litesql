part of 'sql.dart';

Map<Type, TableProto> _enumTypeMap = {};

TableProto? findTableByType(Type type) => _enumTypeMap[type];

void MigrateETable<T extends TableColumn<T>>(LiteSQL lite, List<T> fields) {
  assert(fields.isNotEmpty);
  T first = fields.first;
  if (_enumTypeMap.containsKey(first.tableType)) return;

  List<FieldProto> fieldList = [];
  for (T item in fields) {
    fieldList.add(item.toFieldSqL());
  }

  TableProto tab = TableProto(first.tableName, fieldList);
  _enumTypeMap[first.tableType] = tab;
  lite.migrate(tab);
}
