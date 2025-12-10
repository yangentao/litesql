import 'package:litesql/litesql.dart';
import 'package:test/test.dart';

void main() async {
  test("base-upsert", () {
    LiteSQL lite = LiteSQL.openMemory();
    lite.register(Per.values);

    lite.insert(Per, values: [Per.id >> 1, Per.name >> "entao", Per.age >> 31]);
    lite.dump(Per);
    lite.upsert(Per, values: [Per.id >> 1, Per.age >> 22], constraints: [Per.id, Per.name]);
    lite.dump(Per);
    lite.close();
  });
}

enum Per with TableColumn {
  id(INTEGER(primaryKey: true)),
  name(TEXT(primaryKey: true)),
  age(INTEGER());

  const Per(this.proto);

  @override
  final ColumnProto proto;
}
