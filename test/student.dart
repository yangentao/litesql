import 'package:litesql/litesql.dart';
import 'package:println/println.dart';

void main() {
  LiteSQL lite = LiteSQL.openMemory();
  // lite.migrate(Student.TABLE);

  lite.dispose();
}
