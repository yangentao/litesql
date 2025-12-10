import 'package:litesql/litesql.dart';
import 'package:println/println.dart';
import 'package:test/test.dart';

import '../example/model.dart';

void main() async {
  test("base-returning", () {
    LiteSQL lite = LiteSQL.openMemory();
    lite.register(Person.values);

    Returning returning = Returning([Person.id]);
    lite.insert(Person, values: [Person.name >> "entao", Person.age >> 31], returning: returning);
    println(returning.firstRow);
    // {id: 1}

    Returning r2 = Returning(Person.values);
    lite.upsert(Person, values: [Person.id >> 1, Person.name >> "Tom", Person.age >> 22], constraints: [], returning: r2);
    println(r2.firstRow);
    // {id: 1, name: Tom, age: 22}
    lite.close();
  });
}
