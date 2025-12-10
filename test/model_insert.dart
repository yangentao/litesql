import 'package:litesql/litesql.dart';
import 'package:println/println.dart';
import 'package:test/test.dart';

import '../example/model.dart';

void main() async {
  test("base-insert", () {
    LiteSQL lite = LiteSQL.openMemory();
    lite.register(Person.values);

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
    lite.close();
  });
}
