import 'package:litesql/litesql.dart';
import 'package:test/test.dart';

import '../example/model.dart';

void main() async {
  test("base-update", () {
    LiteSQL lite = LiteSQL.openMemory();
    lite.register(Person.values);

    // INSERT INTO Person ( name,age ) VALUES( ?,? )
    lite.insert(Person, values: [Person.name >> "Entao", Person.age >> 31]);

    // UPDATE Person SET name=? WHERE Person.id = 1
    lite.update(Person, values: [Person.name >> "Tom"], where: Person.id.EQ(1));

    lite.dump(Person);
    lite.close();
  });
}
