## LiteSQL
SQLite with single table ORM..
platform support see  https://pub.dev/packages/sqlite3


## Usage
more example see 'example/\*.dart' and 'test/\*.dart'

* First. define a enum table.  
mixin TableColumn<**Person**> with the enum type it self.  
```dart
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
```

* second. define model
we can use some get/set method to read/write properties.
```dart
class MPerson extends TableModel<Person> {
  MPerson(super.model);
  int get id => Person.id.get(this);
  set id(int value) => this[Person.id] = value;
  String? get name => get(Person.name);
  set name(String? value) => set(Person.name, value);
  int? get age => Person.age.get(this);
  set age(int? value) => Person.age.set(this, value);
}
```

* Insert  
table name can be string value 'Person' or type Person.  
column name can be string value like 'name' or enum value like Person.name.  
'ColumnValue' is defined as `MapEntry<Object, dynamic>`  
`>>` operator return a `ColumnValue`    
the `migrate` method register table and create it when need, also add column/index when need if table is exist, but never delete column/index.  
```dart  
    LiteSQL lite = LiteSQL.openMemory();
    lite.migrate(Person.values);

    lite.insert(Person, values: [ColumnValue("name", "entao2"), Person.age >> 31 ]);
    lite.insertMap("Person", values: {"name": "entao1", "age": 21});
    lite.insertMap(Person, values: {Person.name: "entao1", "age": 21});
    lite.insertValues("Person", columns: [Person.name, "age"], values: ["yang", 11]);

    lite.dump(Person);
    lite.close();
```

* Delete

* Update


* Query

