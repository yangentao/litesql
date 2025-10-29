import 'package:entao_dutil/entao_dutil.dart';
import 'package:litesql/litesql.dart';
import 'package:sqlite3/common.dart';

void main() {
  LiteSQL lite = LiteSQL.openMemory();

  lite.migrateEnumTable(Person.values);
  // CREATE TABLE IF NOT EXISTS Person (
  // id INTEGER PRIMARY KEY,
  // name TEXT,
  // address TEXT,
  // age TEXT
  // )

  int rowid1 = lite.insertRow("Person", ["name" >> "entao1", "age" >> 41, "address" >> "Jinan1"]);
  int rowid2 = lite.insertRow("Person", ["name" >> "entao2", "age" >> 42, "address" >> "Jinan2"]);
  int rowid3 = lite.insertRow("Person", ["name" >> "entao3", "age" >> 43, "address" >> "Jinan3"]);

  EnumTable e = lite.from(Person);
  ResultSet rs = e.query(columns: [Person.id, Person.name], where: Person.id.EQ(2));
  rs.dump();
  // SELECT id, name FROM Person WHERE id = 2
  // id: 2, name: entao2

  var r = e.query(columns: [Person.id.MAX()]);
  r.dump();

  // e.dump();
  lite.dispose();
}

enum Person with ETable<Person> {
  id(EColumn.integer(primaryKey: true)),
  name(EColumn.text()),
  addr(EColumn.text(name: "address")),
  age(EColumn.integer());

  const Person(this.column);

  @override
  final EColumn column;

  @override
  List<Person> get columns => Person.values;
}
