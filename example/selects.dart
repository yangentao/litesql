import 'package:litesql/litesql.dart';
import 'package:println/println.dart';

import 'model.dart';

void main() {
  LiteSQL lite = LiteSQL.openMemory();
  // create/migrate table 'person', and attach 'lite' database to 'Person'
  lite.migrateEnumTable(Person.values);
  lite.migrateEnumTable(Configs.values);
  var a = SELECT(["a", Configs.name, "id"]).FROM(Configs).WHERE(Person.id.GE(1).AND(Person.name.EQ("entao")).AND(Person.add.NE("jinan"))).ORDER_BY(Person.name.DESC).LIMIT(10).OFFSET(5);
  println(a);
}
