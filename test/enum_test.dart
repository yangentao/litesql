// ignore_for_file: unused_local_variable

import 'package:entao_dutil/entao_dutil.dart';
import 'package:litesql/litesql.dart';
import 'package:println/println.dart';

void main() {
  LiteSQL lite = LiteSQL.openMemory();

  lite.migrateEnumTable(Person.values);
  // CREATE TABLE IF NOT EXISTS Person (
  // id INTEGER PRIMARY KEY,
  // name TEXT,
  // address TEXT,
  // age TEXT
  // )
  int rowid1 = lite.insertRow("Person", ["name" >> "entao1", "age" >> 41, "add" >> "Jinan1"]);
  int rowid2 = lite.insertRow("Person", ["name" >> "entao2", "age" >> 42, "add" >> "Jinan2"]);
  int rowid3 = lite.insertRow("Person", ["name" >> "entao3", "age" >> 43, "add" >> "Jinan3"]);

  EnumTable e = lite.from(Person);

  e.insert([Person.name >> "yang", Person.add >> "jinan"]);
  e.dump();

  e.delete(Person.name.EQ("entao3"));

  var rs = e.query(columns: [Person.id, Person.name], where: Person.id.EQ(2));
  rs.dump();
  // SELECT id, name FROM Person WHERE id = 2
  // id: 2, name: entao2

  var r = e.query(columns: [Person.id.MAX()]);
  println("max(id): ", r.firstValue);
  PersonModel? p = e.one(PersonModel.new, where: Person.name.EQ("entao2"));
  println(p);

  MapSQL row = e.query(where: Person.id.EQ(2)).first;
  println(Person.id.get(row), Person.name.get(row), Person.add.get(row), Person.age.get(row));

  println("full: ", Person.name.exGet("fullName"));
  Person.name.exSet("fullName", "this is full name");
  println("full: ", Person.name.exGet("fullName"));

  e.dump();
  lite.dispose();
}

class PersonModel extends TableModel {
  PersonModel(super.mapSQL);

  int get id => Person.id.get(this);

  set id(int value) => this[Person.id] = value;

  String? get name => get(Person.name);

  set name(String? value) => set(Person.name, value);

  String? get addr => get(Person.add);

  set addr(String? value) => set(Person.add, value);

  int? get age => Person.age.get(this);

  set age(int? value) => Person.age.set(this, value);
}

enum Person with TableColumn<Person> {
  id(ColumnSQL.integer(primaryKey: true)),
  name(ColumnSQL.text()),
  add(ColumnSQL.text()),
  age(ColumnSQL.integer());

  const Person(this.column);

  @override
  final ColumnSQL column;

  @override
  List<Person> get columns => Person.values;
}
