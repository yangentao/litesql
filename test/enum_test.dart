// ignore_for_file: unused_local_variable

import 'package:litesql/litesql.dart';
import 'package:println/println.dart';

import '../example/model.dart';

void main() {
  LiteSQL lite = LiteSQL.openMemory();

  lite.migrate(Person.values);
  // CREATE TABLE IF NOT EXISTS Person (
  // id INTEGER PRIMARY KEY,
  // name TEXT,
  // address TEXT,
  // age TEXT
  // )
  // int rowid1 = lite.insertRow("Person", ["name" >> "entao1", "age" >> 41, "add" >> "Jinan1"]);
  // int rowid2 = lite.insertRow("Person", ["name" >> "entao2", "age" >> 42, "add" >> "Jinan2"]);
  // int rowid3 = lite.insertRow("Person", ["name" >> "entao3", "age" >> 43, "add" >> "Jinan3"]);

  SingleTable e = SingleTable(Person);

  MPerson p = MPerson({});
  p.name = "entao";
  p.age = 33;
  p.addr = "jinan";
  int id = p.insert();
  println("id: ", id);
  println(p);

  int r = p.update(() {
    p.age = 99;
    p.addr = "Peiking";
  });
  println("update return: ", r);

  MPerson p2 = MPerson({});
  p2.id = 1;
  p2.name = "yang";
  p2.upsert();
  e.dump();

  p2.delete();

  // e.insert([Person.name >> "yang", Person.add >> "jinan"]);
  // e.dump();
  //
  // e.delete(Person.name.EQ("entao3"));
  //
  // var rs = e.query(columns: [Person.id, Person.name], where: Person.id.EQ(2));
  // rs.dump();
  //
  // var r = e.query(columns: [Person.id.MAX()]);
  // println("max(id): ", r.firstValue);
  // PersonModel? p = e.one(PersonModel.new, where: Person.name.EQ("entao2"));
  // println(p);
  //
  // MapSQL row = e.query(where: Person.id.EQ(2)).first;
  // println(Person.id.get(row), Person.name.get(row), Person.add.get(row), Person.age.get(row));
  //
  // println("full: ", Person.name.exGet("fullName"));
  // Person.name.exSet("fullName", "this is full name");
  // println("full: ", Person.name.exGet("fullName"));
  //
  // List<String> ls = From(Person).listColumn(Person.name);
  // println(ls);

  e.dump();
  lite.close();
}
