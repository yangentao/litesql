


import 'package:litesql/litesql.dart';
import 'package:println/println.dart';
import 'package:test/test.dart';

void main() {
  //
  test("configs", () async {
    LiteSQL lite = LiteSQL.openMemory();
    ConfigsTable t = Configs.use(lite);
    t.migrate();
    t.putString("name", "Entao");
    t.putString("addr", "Jinan");
    t.putInt("age", 44);
    t.putDouble("score", 33.33);
    t.dump();

    String? addr = t.getString("addr");
    println("Addr: ", addr);

    var ls = t.list(Configs.new, orderBy: [Configs.KEY.ASC]);
    for (var e in ls) {
      println(e.key, e.nValue, e.fValue, e.sValue);
    }

    lite.dispose();
  });
}
