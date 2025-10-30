import 'package:litesql/litesql.dart';

void main() {
  LiteSQL lite = LiteSQL.openMemory();
  // lite.migrate(Student.TABLE);

  lite.dispose();
}
