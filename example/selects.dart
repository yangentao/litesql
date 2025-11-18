import 'package:litesql/litesql.dart';
import 'package:println/println.dart';

import 'model.dart';

void main() {
  LiteSQL lite = LiteSQL.openMemory();
  // create/migrate table 'person', and attach 'lite' database to 'Person'
  lite.migrate(Person.values);
  // SingleTable(Person).insertAll([
  //   [Person.name >> "yang"],
  //   [Person.name >> "entao"],
  //   [Person.name >> "yangentao"],
  // ]);

  var ls = lite.tableInfo("Person");
  for (var a in ls) {
    println(a.toJson());
  }

  // From(Person).dump();
  // var r = SELECT([Person.values]).FROM($(Person)).WHERE(Person.name.NOT.GLOB("*en*")).ORDER_BY(Person.name.DESC).LIMIT(10).query(lite);
  // println(r.firstModel(MPerson.new));
}
