import 'package:entao_dutil/entao_dutil.dart';
import 'package:litesql/litesql.dart';
import 'package:println/println.dart';

void main() {
  LiteSQL lite = LiteSQL.openMemory();

  lite.migrateETable(Person.values);

  int rowid1 = lite.insertRow("Person", ["name" >> "entao1", "age" >> 41, "address" >> "Jinan1"]);
  int rowid2 = lite.insertRow("Person", ["name" >> "entao2", "age" >> 42, "address" >> "Jinan2"]);
  int rowid3 = lite.insertRow("Person", ["name" >> "entao3", "age" >> 43, "address" >> "Jinan3"]);

  println(rowid1, rowid2, rowid3);

  lite.dumpTable("Person");
  lite.dispose();
}

enum Person with ETable<Person> {
  id(EColumn.integer(primaryKey: true)),
  name(EColumn()),
  addr(EColumn(name: "address")),
  age(EColumn());

  const Person(this.column);

  @override
  final EColumn column;

  @override
  List<Person> get columns => Person.values;
}
