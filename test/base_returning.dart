import 'package:litesql/litesql.dart';
import 'package:println/println.dart';
import 'package:test/test.dart';

import '../example/model.dart';

void main() async {
  test("base-returning", () {
    LiteSQL lite = LiteSQL.openMemory();
    lite.register(Person.values);

    QueryResult r = lite.insert(Person, values: [Person.name >> "entao", Person.age >> 31], returning: [Person.id]);
    println(r.firstValue());
    expect(r.firstValue(), 1);

    QueryResult r2 = lite.upsert(Person, values: [Person.id >> 1, Person.name >> "Tom", Person.age >> 22], constraints: [], returning: Person.values);
    RowData row = r2.firstRow()!;
    println(row.toMap());
    // {id: 1, name: Tom, age: 22}
    expect(row.get("id"), 1);
    expect(row.get("name"), "Tom");
    expect(row.get("age"), 22);
    lite.close();
  });
}
