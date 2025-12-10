import 'package:entao_dutil/entao_dutil.dart';
import 'package:litesql/litesql.dart';
import 'package:println/println.dart';
import 'package:test/test.dart';

import '../example/model.dart';

void main() async {
  test("base-select", () {
    LiteSQL lite = LiteSQL.openMemory();
    lite.register(Person.values);
    lite.register(Salary.values);

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
    lite.insertAll(
      Salary,
      rows: [
        [Salary.personId >> 1, Salary.base >> 100, Salary.prize >> 200, Salary.total >> 300],
        [Salary.personId >> 2, Salary.base >> 200, Salary.prize >> 200, Salary.total >> 400],
        [Salary.personId >> 3, Salary.base >> 300, Salary.prize >> 200, Salary.total >> 500],
        [Salary.personId >> 4, Salary.base >> 400, Salary.prize >> 200, Salary.total >> 600],
      ],
    );
    // SELECT Person.id, Person.name, Person.age FROM Person WHERE Person.age >= 40
    List<MPerson> ps = SELECT([Person.id, Person.name, Person.age]).FROM(Person)
        .WHERE(Person.age.GE(40))
        .query(lite).listModels(MPerson.new );
    for(var p in ps ){
      println(p);
    }
    // {"id":3,"name":"name3","age":40}
    // {"id":4,"name":"name4","age":50}

    // SELECT Person.id, Person.name, Salary.total FROM Person JOIN Salary ON Person.id = Salary.personId WHERE Salary.total >= 500
    List<AnyMap> ls = lite.query([Person.id, Person.name, Salary.total],
        from: $(Person).JOIN(Salary).ON(Person.id.EQ(Salary.personId)  ),
        where: Salary.total.GE(500),
    ).listRows();

    for (var r in ls) {
      println(r);
    }
    // {id: 3, name: name3, total: 500.0}
    // {id: 4, name: name4, total: 600.0}

    lite.dump(Salary);
    lite.dump(Person);
    lite.close();
  });

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
