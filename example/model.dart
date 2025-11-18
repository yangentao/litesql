import 'package:litesql/litesql.dart';

class MPerson extends TableModel<Person> {
  MPerson(super.model);

  int get id => Person.id.get(this);

  set id(int value) => this[Person.id] = value;

  String? get name => get(Person.name);

  set name(String? value) => set(Person.name, value);

  String? get addr => get(Person.addr);

  set addr(String? value) => set(Person.addr, value);

  int? get age => Person.age.get(this);

  set age(int? value) => Person.age.set(this, value);
}

enum Person with TableColumn<Person> {
  id(INTEGER(primaryKey: true)),
  name(TEXT()),
  addr(TEXT()),
  age(INTEGER());

  const Person(this.proto);

  @override
  final ColumnProto proto;

  @override
  List<Person> get columns => Person.values;
}
