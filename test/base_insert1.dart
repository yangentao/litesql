import 'package:litesql/litesql.dart';
import 'package:test/test.dart';

import '../example/model.dart';

void main() async {
  test("base-insert", () {
    LiteSQL lite = LiteSQL.openMemory();
    lite.migrate(Person.values);

    lite.insert(Person, values: [ColumnValue("name", "entao2"), ColumnValue(Person.age, 31), Person.addr >> "Jinan2"]);
    lite.insertMap("Person", values: {"name": "entao1", "age": 21});
    lite.insertMap(Person, values: {Person.name: "entao1", "age": 21});
    lite.insertValues("Person", columns: [Person.name, "age"], values: ["yang", 11]);

    lite.dump(Person);
  });
}
