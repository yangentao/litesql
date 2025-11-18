import 'package:litesql/litesql.dart';
import 'package:println/println.dart';

import 'model.dart';

void main() {
  LiteSQL lite = LiteSQL.openMemory();
  // create/migrate table 'person', and attach 'lite' database to 'Person'
  lite.migrateEnum(Person.values);
  // output:
  // CREATE TABLE IF NOT EXISTS Person (
  // id INTEGER PRIMARY KEY,
  // name TEXT,
  // address TEXT,
  // age TEXT
  // )
  EnumTable tab = From(Person);

  tab.insert([Person.name >> "yang1", Person.add >> "jinan1"]);
  tab.insert([Person.name >> "yang2", Person.add >> "jinan2"]);
  // 2025-10-31 14:33:25.781 D xlog: INSERT  INTO Person (name,"add") VALUES (?,?)
  // 2025-10-31 14:33:25.785 D xlog: INSERT  INTO Person (name,"add") VALUES (?,?)
  tab.dump();
  // {id: 1, name: yang1, add: jinan1, age: null}
  // {id: 2, name: yang2, add: jinan2, age: null}

  List<MPerson> ls = tab.list(MPerson.new, where: Person.name.EQ("yang2"));
  // SELECT * FROM Person WHERE name = ?
  println(ls);
  // [{"id":2,"name":"yang2","add":"jinan2","age":null}]

  tab.delete(Person.name.EQ("yang2"));
  // 2025-10-31 14:33:25.787 D xlog: DELETE FROM Person WHERE name = ?
  tab.dump();
  // {id: 1, name: yang1, add: jinan1, age: null}


  lite.close();
}
