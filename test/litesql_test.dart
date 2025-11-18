import 'package:litesql/litesql.dart';
import 'package:println/println.dart';
import 'package:test/test.dart';

void main() {
  //
  test("configs", () async {
    LiteSQL lite = LiteSQL.openMemory();
    lite.migrateEnum(Configs.values);

    MConfigs.putString("name", "Entao");
    MConfigs.putString("addr", "Jinan");
    MConfigs.putInt("age", 44);
    MConfigs.putDouble("score", 33.33);
    EnumTable tab = From(Configs);
    tab.dump();

    String? addr = MConfigs.getString("addr");
    println("Addr: ", addr);

    var ls = tab.list(MConfigs.new, orders: [Configs.name.ASC]);
    for (var e in ls) {
      println(e.name, e.nValue, e.fValue, e.sValue);
    }

    lite.close();
  });
}
