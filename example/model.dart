import 'package:litesql/litesql.dart';

class MPerson extends TableModel<Person> {
  MPerson(super.model);

  static EnumTable table() => tableOfType(Person);

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

  static EnumTable table() => tableOfType(Person);
}
