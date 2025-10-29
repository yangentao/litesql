part of 'sql.dart';

Map<Type, TableSQL> _enumTypeMap = {};

TableSQL? findTableByType(Type type) => _enumTypeMap[type];

void MigrateETable<T extends ETable<T>>(LiteSQL lite, List<T> fields) {
  assert(fields.isNotEmpty);
  T first = fields.first;
  if (_enumTypeMap.containsKey(first.tableType)) return;

  List<FieldSQL> fieldList = [];
  for (T item in fields) {
    fieldList.add(item.toFieldSqL());
  }

  TableSQL tab = TableSQL(first.tableName, fieldList);
  lite.migrate(tab);
  _enumTypeMap[first.tableType] = tab;
}
