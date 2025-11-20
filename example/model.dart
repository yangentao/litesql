import 'package:litesql/litesql.dart';

class MPerson extends TableModel<Person> {
  MPerson(super.model);

  int get id => Person.id.get(this);

  set id(int value) => this[Person.id] = value;

  String? get name => get(Person.name);

  set name(String? value) => set(Person.name, value);

  int? get age => Person.age.get(this);

  set age(int? value) => Person.age.set(this, value);

  static final table = TableOf(MPerson.new);
}

enum Person with TableColumn<Person> {
  id(INTEGER(primaryKey: true)),
  name(TEXT()),
  age(INTEGER());

  const Person(this.proto);

  @override
  final ColumnProto proto;

  @override
  List<Person> get columns => Person.values;
}

class MSalary extends TableModel<Salary> {
  MSalary(super.model);

  int get personId => get(Salary.personId);

  double get base => get(Salary.base);

  double get prize => get(Salary.prize);

  double get total => get(Salary.total);
}

enum Salary with TableColumn<Salary> {
  personId(INTEGER(primaryKey: true)),
  total(REAL()),
  base(REAL()),
  prize(REAL());

  const Salary(this.proto);

  @override
  final ColumnProto proto;

  @override
  List<Salary> get columns => Salary.values;
}
