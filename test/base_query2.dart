import 'package:litesql/litesql.dart';
import 'package:println/println.dart';
import 'package:test/test.dart';

import '../example/model.dart';

void main() async {
  test("base-query", () {
    LiteSQL lite = LiteSQL.openMemory();
    lite.register(Person.values);

    lite.insertAllValues(
      Person,
      columns: [Person.name, Person.age],
      rows: [
        ["name1", 20],
        ["name2", 30],
        ["name3", 40],
        ["name4", 50],
      ],
    );
    // query(columns, ...), columns can be empty, means ALL column, or ["*"]
    List<MPerson> ls = lite.query([], from: Person, where: Person.age.GE(40), orderBy: Person.name.DESC).listModels(MPerson.new);
    for (var p in ls) {
      println(p);
    }
    // {"id":4,"name":"name4","age":50}
    // {"id":3,"name":"name3","age":40}
    List<int> ids = lite.query([Person.id], from: Person, where: Person.age.GE(40), orderBy: Person.name.DESC).listValues();
    println(ids);
    // [4, 3]

    lite.dump(Person);
    lite.close();
  });
}
