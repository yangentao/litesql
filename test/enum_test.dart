// ignore_for_file: unused_local_variable

import 'package:entao_dutil/entao_dutil.dart';
import 'package:litesql/litesql.dart';
import 'package:println/println.dart';

void main() {
  LiteSQL lite = LiteSQL.openMemory();

  lite.migrateEnumTable(PersonT.values);
  // CREATE TABLE IF NOT EXISTS Person (
  // id INTEGER PRIMARY KEY,
  // name TEXT,
  // address TEXT,
  // age TEXT
  // )
  int rowid1 = lite.insertRow("Person", ["name" >> "entao1", "age" >> 41, "add" >> "Jinan1"]);
  int rowid2 = lite.insertRow("Person", ["name" >> "entao2", "age" >> 42, "add" >> "Jinan2"]);
  int rowid3 = lite.insertRow("Person", ["name" >> "entao3", "age" >> 43, "add" >> "Jinan3"]);

  EnumTable e = lite.from(PersonT);

  e.insert([PersonT.name >> "yang", PersonT.add >> "jinan"]);
  e.dump();

  e.delete(PersonT.name.EQ("entao3"));

  var rs = e.query(columns: [PersonT.id, PersonT.name], where: PersonT.id.EQ(2));
  rs.dump();
  // SELECT id, name FROM Person WHERE id = 2
  // id: 2, name: entao2

  var r = e.query(columns: [PersonT.id.MAX()]);
  println("max(id): ", r.firstValue);
  PersonModel? p = e.one(PersonModel.new, where: PersonT.name.EQ("entao2"));
  println(p);

  MapSQL row = e.query(where: PersonT.id.EQ(2)).first;
  println(PersonT.id.get(row), PersonT.name.get(row), PersonT.add.get(row), PersonT.age.get(row));

  println("full: ", PersonT.name.exGet("fullName"));
  PersonT.name.exSet("fullName", "this is full name");
  println("full: ", PersonT.name.exGet("fullName"));

  e.dump();
  lite.dispose();
}

class PersonModel extends TableModel {
  PersonModel(super.model);

  int get id => PersonT.id.get(this);

  set id(int value) => this[PersonT.id] = value;

  String? get name => get(PersonT.name);

  set name(String? value) => set(PersonT.name, value);

  String? get addr => get(PersonT.add);

  set addr(String? value) => set(PersonT.add, value);

  int? get age => PersonT.age.get(this);

  set age(int? value) => PersonT.age.set(this, value);
}

enum PersonT with TableColumn<PersonT> {
  id(ColumnSQL.integer(primaryKey: true)),
  name(ColumnSQL.text()),
  add(ColumnSQL.text()),
  age(ColumnSQL.integer());

  const PersonT(this.column);

  @override
  final ColumnSQL column;

  @override
  List<PersonT> get columns => PersonT.values;
}
