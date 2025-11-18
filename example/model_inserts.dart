import 'package:litesql/litesql.dart';
import 'package:println/println.dart';

import 'model.dart';

void main() {
  LiteSQL lite = LiteSQL.openMemory();
  lite.migrate(Person.values);
  MPerson p = MPerson({});
  p.name = "entao";
  p.age = 33;
  p.addr = "jinan";
  p.upsert(columns: [Person.name, Person.age]);
  // int id = p.upsert(names: ['name', 'age']);
  println(p);

  SingleTable(Person).dump();
  lite.close();
}
