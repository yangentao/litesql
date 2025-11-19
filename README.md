## LiteSQL
SQLite with table ORM.  
platform support see  https://pub.dev/packages/sqlite3
## Usage
more example see 'example/\*.dart' and 'test/\*.dart'

* First. define a enum table.  
mixin TableColumn<**Person**> with the enum type as generic parameter.  
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

* second. define model, also with enum type `Person` as generic parameter.  
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
the `migrate` method register table and create it when need, also add column/index when need if table is exist, but never delete them.  
```dart  
LiteSQL lite = LiteSQL.openMemory();
lite.migrate(Person.values);

lite.insert(Person, values: [Person.name >> "entao1", Person.age >> 31 ]);

lite.insertMap("Person", values: {"name": "entao2", "age": 21});
lite.insertMap(Person, values: {Person.name: "entao3", "age": 21});

lite.insertValues("Person", columns: [Person.name, "age"], values: ["entao4", 11]);

lite.dump(Person);
lite.close();
```

* Delete  
String and Enum value has some extension method like 'EQ','GE','LE','LT'...  
'&' means 'AND', '|' means 'OR'  
`Where` will pass `String` value as parameter, but num is direct placed.  
```dart  
// DELETE FROM Person WHERE Person.id = 1
lite.delete(Person, where: Person.id.EQ(1));
// DELETE FROM Person WHERE id = 2 AND Person.name = ? OR Person.id = 3
lite.delete("Person", where: "id".EQ(2) & Person.name.EQ("entao2") | Person.id.EQ(3));
```
* Update

```dart  
// UPDATE Person SET name=? WHERE Person.id = 1
lite.update(Person, values: [Person.name >> "Tom"], where: Person.id.EQ(1));
```

* Query

```dart  
lite.insertAllValues(
  Person,
  columns: [Person.name, Person.age],
  rows: [
    ["name1", 20],
    ["name2", 30],
    ["name3", 40],
    ["name4", 50],
  ],
);
// query(columns, ...), columns can be empty, means ALL column, or ["*"]
List<MPerson> ls = lite.query([], from: Person, where: Person.age.GE(40), orderBy: Person.name.DESC).listModels(MPerson.new);
for (var p in ls) {
  println(p);
}
// {"id":4,"name":"name4","age":50}
// {"id":3,"name":"name3","age":40}
List<int> ids = lite.query([Person.id], from: Person, where: Person.age.GE(40), orderBy: Person.name.DESC).listValues();
println(ids);
// [4, 3]
```
