import 'package:litesql/litesql.dart';
import 'package:println/println.dart';
import 'package:test/test.dart';

import '../example/model.dart';

void main() async {
  test("single-insert", () {
    LiteSQL lite = LiteSQL.openMemory();
    lite.migrate(Person.values);


    MPerson.table.insert(values: [Person.name >> "entao", Person.age >> 11]);
    MPerson.table.insert(values: [Person.name >> "entao2", Person.age >> 22]);
    // MPerson.table.deleteBy(key: 1);
    List<MPerson> ls = MPerson.table.listModel();
    println(ls);
    MPerson? p = MPerson.table.oneByKey(key: 1);
    p?.age = 33;
    MPerson.table.save(p );
    println(p);

    lite.dump(Person);
    lite.close();
  });
}
