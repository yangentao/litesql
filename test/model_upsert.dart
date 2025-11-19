import 'package:litesql/litesql.dart';
import 'package:println/println.dart';
import 'package:test/test.dart';

import '../example/model.dart';

void main() async {
  test("base-insert", () {
    LiteSQL lite = LiteSQL.openMemory();
    lite.migrate(Person.values);

    MPerson p = MPerson({});
    p.name = "entao1";
    p.age = 33;
    p.upsert();
    // INSERT INTO Person ( name,age ) VALUES( ?,? ) ON CONFLICT( id ) DO UPDATE SET name=?, age=?  RETURNING *
    println(p);
    // {"name":"entao1","age":33,"id":1}

    p.age = 22;
    p.upsert();
    // INSERT INTO Person ( id,name,age ) VALUES( ?,?,? ) ON CONFLICT( id ) DO UPDATE SET name=?, age=?  RETURNING *

    lite.dump(Person);
    // {id: 1, name: entao1, age: 22}
    lite.close();
  });
}
