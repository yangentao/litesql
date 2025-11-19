import 'package:litesql/litesql.dart';
import 'package:println/println.dart';

import 'model.dart';

void main() {
  LiteSQL lite = LiteSQL.openMemory();
  // create/migrate table 'person', and attach 'lite' database to 'Person'
  lite.migrate(Person.values);
  // output:
  // CREATE TABLE IF NOT EXISTS Person (
  // id INTEGER PRIMARY KEY,
  // name TEXT,
  // address TEXT,
  // age TEXT
  // )
  SingleTable tab = SingleTable(Person);

  // {id: 1, name: yang1, add: jinan1, age: null}
  // {id: 2, name: yang2, add: jinan2, age: null}

  // List<MPerson> ls = tab.list(MPerson.new, where: Person.name.EQ("yang2"));
  // SELECT * FROM Person WHERE name = ?
  // println(ls);
  // [{"id":2,"name":"yang2","add":"jinan2","age":null}]

  tab.delete(Person.name.EQ("yang2"));
  // 2025-10-31 14:33:25.787 D xlog: DELETE FROM Person WHERE name = ?
  tab.dump();
  // {id: 1, name: yang1, add: jinan1, age: null}

  lite.close();
}
