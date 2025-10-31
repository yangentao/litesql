## LiteSQL

SQLite wrap for package 'sqlite3'.

## Usage
more example see 'example/xxx_example.dart'

* first. define a enum table.
```dart

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

 static EnumTable table() => FromTable(Person);
}

```

* second. defint model
```dart
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

```

* third. use table.
```dart 
void main() {
 LiteSQL lite = LiteSQL.openMemory();
 // create/migrate table 'person', and attach 'lite' database to 'Person'
 lite.migrateEnumTable(Person.values);
 // output:
 // CREATE TABLE IF NOT EXISTS Person (
 // id INTEGER PRIMARY KEY,
 // name TEXT,
 // address TEXT,
 // age TEXT
 // )

 MPerson p = MPerson({});
 p.name = "entao";
 p.age = 33;
 p.addr = "jinan";
 int id = p.insert();
 // 2025-10-31 14:25:57.080 D xlog: INSERT  INTO Person (name,age,"add") VALUES (?,?,?)
 println("enum insert, id= ", id, ", person:", p);
 // enum insert, id=  1 , person: {"name":"entao","age":33,"add":"jinan","id":1}
 From(Person).dump();
 // {id: 1, name: entao, add: jinan, age: 33}

 int r = p.update(() {
  p.age = 99;
  p.addr = "Peiking";
 });
 // 2025-10-31 14:28:10.793 D xlog: UPDATE Person SET age = ?, "add" = ? WHERE id = 1
 println("update : count=", r, " , person: ", p);
 // update : count= 1  , person:  {"name":"entao","age":99,"add":"Peiking","id":1}
 From(Person).dump();
 // {id: 1, name: entao, add: Peiking, age: 99}

 MPerson p2 = MPerson({});
 p2.id = 1;
 p2.name = "yang";
 p2.upsert();
 // 2025-10-31 14:30:04.384 D xlog: INSERT INTO Person (id, name) VALUES ( ?, ? ) ON CONFLICT (id) DO UPDATE SET name = ?
 // 2025-10-31 14:30:04.384 D xlog: [1, yang, yang]
 List<MPerson> ls = From(Person).list(MPerson.new);
 // SELECT * FROM Person
 println(ls);
 // [{"id":1,"name":"yang","add":"Peiking","age":99}]

 p2.delete();
 // 2025-10-31 14:30:04.385 D xlog: DELETE FROM Person WHERE id = 1
 From(Person).dump();
 // [no output]

 lite.dispose();
}
 

```
 