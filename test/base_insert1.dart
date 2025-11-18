import 'package:litesql/litesql.dart';
import 'package:println/println.dart';
import 'package:test/test.dart';

import '../example/model.dart';

void main() async {
  test("x-query", () {
    LiteSQL lite = LiteSQL.openMemory();
    lite.migrate(Person.values);
    lite.insertMap("Person", {"name": "entao1", "age": 21, "add": "Jinan1"});
    lite.insertMap("Person", {"name": "entao2", "age": 31, "add": "Jinan2"});
    lite.insertMap("Person", {"name": "entao3", "age": 41, "add": "Jinan3"});
    lite.insertMap("Person", {"name": "entao4", "age": 41, "add": "Jinan4"});
    lite.insertMap("Person", {Person.name: "yang", Person.age: 22, "add": "Peiking"});

    List<MPerson> ps = lite
        .query(Person.values, from: Person, where: Person.age.GE(42) & Person.addr.GLOB("*an2"), orderBy: [Person.age.ASC, Person.name.DESC])
        .allModels(MPerson.new);
    println(ps);

    lite.dumpTable("Person");
  });
}
