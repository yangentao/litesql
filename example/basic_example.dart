import 'package:litesql/litesql.dart';
import 'package:println/println.dart';
import 'package:sqlite3/common.dart';

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
  lite.insertMap("Person", {"name": "entao1", "age": 21, "add": "Jinan1"});
  lite.insertMap("Person", {"name": "entao2", "age": 31, "add": "Jinan2"});
  lite.insertMap("Person", {"name": "entao3", "age": 41, "add": "Jinan3"});
  lite.insertMap("Person", {"name": "entao4", "age": 41, "add": "Jinan4"});
  // 2025-10-31 14:19:53.214 D xlog: INSERT  INTO Person (name,age,"add") VALUES (?,?,?)
  // 2025-10-31 14:19:53.217 D xlog: INSERT  INTO Person (name,age,"add") VALUES (?,?,?)
  // 2025-10-31 14:19:53.217 D xlog: INSERT  INTO Person (name,age,"add") VALUES (?,?,?)

  ResultSet rs = lite.query(['id', 'name'], from: 'Person', where: 'age=22');
  // SELECT id, name FROM Person WHERE age=22
  for (Row row in rs) {
    println(row['id'], row['name']);
    // 2 entao2
  }

  lite.dumpTable('Person');
  // {id: 1, name: entao1, add: Jinan1, age: 21}
  // {id: 2, name: entao2, add: Jinan2, age: 22}
  // {id: 3, name: entao3, add: Jinan3, age: 23}

  lite.close();
}
