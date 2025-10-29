part of 'sql.dart';

Map<Type, TableSQL> _enumTypeMap = {};

TableSQL? _findTableProto(Type type) => _enumTypeMap[type];

void MigrateETable<T extends ETable<T>>(LiteSQL lite, List<T> fields) {
  assert(fields.isNotEmpty);
  T first = fields.first;
  if (null != _findTableProto(first.tableType)) return;

  List<FieldSQL> fieldList = [];
  for (T item in fields) {
    fieldList.add(item.toFieldSqL());
  }

  TableSQL tab = TableSQL(first.tableName, fieldList);
  lite.migrate(tab);
  _enumTypeMap[first.tableType] = tab;
}
