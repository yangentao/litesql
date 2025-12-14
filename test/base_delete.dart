import 'package:entao_log/entao_log.dart';
import 'package:litesql/litesql.dart';
import 'package:test/test.dart';

import '../example/model.dart';

void main() async {
  test("base-delete", () {
    xlog.pipe(ConsolePrinter());
    LiteSQL lite = LiteSQL.openMemory();
    lite.register(Person.values);

    lite.insert(Person, values: [ColumnValue("name", "entao1"), Person.age >> 31]);
    lite.insertMap("Person", values: {"name": "entao2", "age": 21});
    lite.insertMap(Person, values: {Person.name: "entao3", "age": 21});
    lite.insertValues("Person", columns: [Person.name, "age"], values: ["entao4", 11]);

    // DELETE FROM Person WHERE Person.id = 1
    lite.delete(Person, where: Person.id.EQ(1));
    // DELETE FROM Person WHERE id = 2 AND Person.name = ? OR Person.id = 3
    lite.delete("Person", where: "id".EQ(2) & Person.name.EQ("entao2") | Person.id.EQ(3));

    lite.dump(Person);
    lite.close();
  });
}
