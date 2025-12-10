import 'package:litesql/litesql.dart';
import 'package:println/println.dart';
import 'package:test/test.dart';

import '../example/model.dart';

void main() async {
  test("single-table", () {
    LiteSQL lite = LiteSQL.openMemory();
    lite.register(Person.values);

    var table = TableOf(MPerson.new);
    table.insert(values: [Person.name >> "entao", Person.age >> 11]);
    table.insert(values: [Person.name >> "Tom", Person.age >> 22]);

    List<MPerson> ls = table.listModel(where: Person.name.NOTNULL);
    println(ls);
    // [{"id":1,"name":"entao","age":11}, {"id":2,"name":"Tom","age":22}]

    MPerson? p = table.oneBy(key: 1);
    p?.age = 33;
    table.save(p);
    println(p);
    // {"id":1,"name":"entao","age":33}

    table.dump();
    // {id: 1, name: entao, age: 33}
    // {id: 2, name: Tom, age: 22}
    lite.close();
  });
}
