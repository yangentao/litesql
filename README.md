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
operator `>>`  return a `ColumnValue`    
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
* Upsert.  

```dart  
lite.insert(Person, values: [Person.name >> "entao", Person.age >> 31]);
lite.dump(Person);
// {id: 1, name: entao, age: 31}
// lite.upsert(Person, values: [Person.id >> 1, Person.name >> "Tom", Person.age >> 22], constraints: [Person.id]);
lite.upsert(Person, values: [Person.id >> 1, Person.name >> "Tom", Person.age >> 22], constraints: []); // same as above line.
// INSERT INTO Person ( id,name,age ) VALUES( ?,?,? ) ON CONFLICT( id ) DO UPDATE SET name=?, age=?  
lite.dump(Person);
// {id: 1, name: Tom, age: 22}
```
when parameter 'constraints' is empty, it will auto search from 'values', which column is defined in enum class 'Person'.
  
* Returning  
insert/upsert/delete/update can return the effect row data, part or whole.  
```dart  
Returning returning = Returning([Person.id]);
lite.insert(Person, values: [Person.name >> "entao", Person.age >> 31], returning: returning);
println(returning.firstRow);
// {id: 1}
Returning r2 = Returning(Person.values);
lite.upsert(Person, values: [Person.id >> 1, Person.name >> "Tom", Person.age >> 22], constraints: [], returning: r2);
println(r2.firstRow);
// {id: 1, name: Tom, age: 22}
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
`query` method can used for multi table query.  
the `from` parameter can be a 'join-on/using' clause.  
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

* Query, multi tables.

```dart  
// SELECT Person.id, Person.name, Salary.total FROM Person 
// JOIN Salary ON Person.id = Salary.personId WHERE Salary.total >= 500
List<AnyMap> ls = lite.query([Person.id, Person.name, Salary.total],
    from: $(Person).JOIN(Salary).ON(Person.id.EQ(Salary.personId)),
    where: Salary.total.GE(500),
).listRows();
for (var r in ls) {
  println(r);
}
// {id: 3, name: name3, total: 500.0}
// {id: 4, name: name4, total: 600.0}
```

'ON' clause is 'Where' express. but 'Where' will pass String value as parameter to sqlite.  
so, sometimes we need change String value to 'Express'.  

`ON(Person.id.EQ(Salary.personId) & Person.name.NE(Salary.leaderName))`  OK.  
`ON(Person.id.EQ(Salary.personId) & Person.name.NE("Salary.leaderName"))`  BAD.  
`ON(Person.id.EQ(Salary.personId) & Person.name.NE("Salary.leaderName".express))`  OK.  
`ON(Person.id.EQ(Salary.personId) & Person.name.NE(Express("Salary.leaderName")))`  OK.

* Select.  

```dart  
// SELECT Person.id, Person.name, Person.age FROM Person WHERE Person.age >= 40
List<MPerson> ps = SELECT([Person.id, Person.name, Person.age]).FROM(Person)
    .WHERE(Person.age.GE(40))
    .query(lite).listModels(MPerson.new );
for(var p in ps ){
  println(p);
}
// {"id":3,"name":"name3","age":40}
// {"id":4,"name":"name4","age":50}
```

* Model insert

```dart  
MPerson p = MPerson({});
p.name = "entao1";
p.age = 33;
p.insert();
println(p);
// {"name":"entao1","age":33,"id":1}

// p.removeProperty(Person.id);
p.insert(columns: [Person.name]); // ONLY name be insert
// INSERT INTO Person ( name ) VALUES( ? )  RETURNING *

lite.dump(Person);
// {id: 1, name: entao1, age: 33}
// {id: 2, name: entao1, age: null}
```
* Model upsert
```dart  
MPerson p = MPerson({});
p.name = "entao1";
p.age = 33;
p.upsert();
// INSERT INTO Person ( name,age ) VALUES( ?,? ) ON CONFLICT( id ) DO UPDATE SET name=?, age=?  RETURNING *
println(p);
// {"name":"entao1","age":33,"id":1}
p.age = 22;
p.upsert();
// INSERT INTO Person ( id,name,age ) VALUES( ?,?,? ) ON CONFLICT( id ) DO UPDATE SET name=?, age=?  RETURNING *
lite.dump(Person);
// {id: 1, name: entao1, age: 22}

```

* Model update

```dart  
MPerson p = MPerson({});
p.name = "entao1";
p.age = 33;
p.insert();
// INSERT INTO Person ( name,age ) VALUES( ?,? )  RETURNING *
println(p);
// {"name":"entao1","age":33,"id":1}
p.update(() {
  p.name = "Tom";
  p.age = 5;
});
// UPDATE Person SET name=?, age=? WHERE Person.id = 1  RETURNING *
lite.dump(Person);
// {id: 1, name: Tom, age: 5}
```