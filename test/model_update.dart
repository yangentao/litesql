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

    lite.close();
  });
}
