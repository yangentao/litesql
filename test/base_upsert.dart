import 'package:litesql/litesql.dart';
import 'package:test/test.dart';

import '../example/model.dart';

void main() async {
  test("base-upsert", () {
    LiteSQL lite = LiteSQL.openMemory();
    lite.register(Person.values);

    lite.insert(Person, values: [Person.name >> "entao", Person.age >> 31]);
    lite.dump(Person);
    // {id: 1, name: entao, age: 31}
    // lite.upsert(Person, values: [Person.id >> 1, Person.name >> "Tom", Person.age >> 22], constraints: [Person.id]);
    lite.upsert(Person, values: [Person.id >> 1, Person.name >> "Tom", Person.age >> 22], constraints: []);
    // INSERT INTO Person ( id,name,age ) VALUES( ?,?,? ) ON CONFLICT( id ) DO UPDATE SET name=?, age=?
    lite.dump(Person);
    // {id: 1, name: Tom, age: 22}

    lite.close();
  });
}
