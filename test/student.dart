import 'package:litesql/litesql.dart';
import 'package:println/println.dart';

void main() {
  LiteSQL lite = LiteSQL.openMemory();
  lite.migrate(Student.TABLE);
  SingleTable table = lite.table(Student.TABLE);

  table.insert([Student.NAME >> "entao", Student.SCORE >> 90]);
  table.insert([Student.NAME >> "yang", Student.SCORE >> 88]);
  List<Student> ls = table.list(Student.new);
  for (var a in ls) {
    println(a);
  }

  lite.dispose();
}

class Student extends ModelSQL {
  Student(super.mapSQL);

  int get id => ID.get(this);

  set id(int value) => ID.set(this, value);

  String get name => NAME.get(this);

  set name(String value) => NAME.set(this, value);

  double? get score => SCORE.get(this);

  set score(double? value) => SCORE.set(this, value);

  static FieldSQL ID = FieldSQL.integer(name: "id", primaryKey: true, autoInc: true);
  static FieldSQL NAME = FieldSQL.text(name: "name", notNull: true);
  static FieldSQL SCORE = FieldSQL.real(name: "score", index: true);

  static TableSQL TABLE = TableSQL("student", [ID, NAME, SCORE]);

  static SingleTable table(LiteSQL lite) => SingleTable(lite: lite, table: TABLE);
}
