import 'package:println/println.dart';

void main() {
  createTable<Stu>(Stu.values);
}

void createTable<T extends XTableField>(List<T> fields) {
  dynamic v = T ;
  println("values: ", v.values);

  T first = fields.first;
  println(first.tableName, first.index, first.name);
  for (var e in fields.first.all) {}
  for (T a in fields) {
    println(a.index, a.name, a.info.type);
  }
}

enum Stu with XTableField<Stu> {
  a(FieldInfo(name: 'a')),
  b(FieldInfo(name: "b "));

  const Stu(this.info);

  @override
  final FieldInfo info;

  @override
  List<Stu> get all => Stu.values;
}

mixin XTableField<T extends Enum> on Enum  {
  String get tableName => "$T";

  FieldInfo get info;

  List<XTableField> get all;
}

class FieldInfo {
  final String name;
  final String type;

  const FieldInfo({required this.name, this.type = "TEXT"});
}
