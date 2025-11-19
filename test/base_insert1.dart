import 'package:litesql/litesql.dart';
import 'package:test/test.dart';

import '../example/model.dart';

void main() async {
  test("base-insert", () {
    LiteSQL lite = LiteSQL.openMemory();
    lite.migrate(Person.values);

    lite.insert(Person, values: [Person.name >> "entao1", Person.age >> 31 ]);

    lite.insertMap("Person", values: {"name": "entao2", "age": 21});
    lite.insertMap(Person, values: {Person.name: "entao3", "age": 21});
    lite.insertValues("Person", columns: [Person.name, "age"], values: ["entao4", 11]);

    lite.dump(Person);
    lite.close();
  });
}
