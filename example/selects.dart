import 'package:litesql/litesql.dart';
import 'package:println/println.dart';

import 'model.dart';

void main() {
  LiteSQL lite = LiteSQL.openMemory();
  // create/migrate table 'person', and attach 'lite' database to 'Person'
  lite.migrateEnumTable(Person.values);
  lite.migrateEnumTable(Configs.values);
  var a = SELECT(["a", Configs.name, "id"]).FROM(Configs);
  println(a);
}
