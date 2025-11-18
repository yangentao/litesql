import 'package:entao_dutil/entao_dutil.dart';
import 'package:litesql/litesql.dart';
import 'package:println/println.dart';
import 'package:test/test.dart';

import '../example/model.dart';

void main() async {
  test("x-query", () {
    LiteSQL lite = LiteSQL.openMemory();
    lite.migrate(Person.values);
    lite.insert("Person", ["name" >> "entao1", "age" >> 41, "add" >> "Jinan1"]);
    lite.insert("Person", ["name" >> "entao2", "age" >> 42, "add" >> "Jinan2"]);
    lite.insert("Person", ["name" >> "entao3", "age" >> 43, "add" >> "Jinan3"]);

    List<MPerson> ps = lite.X
        .query(Person.values, from: Person, where: Person.age.GE(42) & Person.add.GLOB("*an2"), orderBy: [Person.age.ASC, Person.name.DESC])
        .allModels(MPerson.new);
    println(ps);

    lite.dumpTable("Person");
  });
}
