import 'package:litesql/litesql.dart';
import 'package:println/println.dart';

import 'model.dart';

void main() {
  LiteSQL lite = LiteSQL.openMemory();
  // create/migrate table 'person', and attach 'lite' database to 'Person'
  lite.migrate(Person.values);
  From(Person).insertAll([
    [Person.name >> "yang"],
    [Person.name >> "entao"],
    [Person.name >> "yangentao"],
  ]);
  From(Person).dump();
  var r = SELECT([Person.values]).FROM($(Person)).WHERE(Person.name.NOT.GLOB("*en*")).ORDER_BY(Person.name.DESC).LIMIT(10).query(lite);
  println(r.firstModel(MPerson.new));
}
