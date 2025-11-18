import 'package:litesql/litesql.dart';
import 'package:println/println.dart';

import 'model.dart';

void main() {
  LiteSQL lite = LiteSQL.openMemory();
  // create/migrate table 'person', and attach 'lite' database to 'Person'
  lite.migrateEnumTable(Person.values);
  lite.migrateEnumTable(Configs.values);
  var a = SELECT([Person.values, Configs.name, "id"])
      .FROM(TABLE(Configs).JOIN(Person).ON(Configs.name.EQ(Person.name)))
      .WHERE((Person.id.GE(1) | Person.name.EQ("entao")).braced & Person.add.NE("jinan"))
      .WINDOW("w1", [PARTITION_BY(Person.id), ORDER_BY(Person.name.DESC)])
      .ORDER_BY(Person.name.DESC)
      .LIMIT(10)
      .OFFSET(5);
  println(a);

}

class AA {}

extension AAA on Type {
  String hello() => "Hello";
}

extension type MyInt(int value) implements int {
  static void hello() {
    println("Hello");
  }
}
