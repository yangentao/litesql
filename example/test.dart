import 'package:litesql/litesql.dart';
import 'package:println/println.dart';

void main() {
  LiteSQL lite = LiteSQL.openMemory();
  lite.migrate(Configs.values);
  MConfigs.putInt("age", 99);
  println("age is null? ", MConfigs.getInt("age"));
  lite.close();
}
