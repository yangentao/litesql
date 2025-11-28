import 'package:litesql/litesql.dart';

void main() {
  LiteSQL lite = LiteSQL.openMemory();
  lite.createTable("hello", ["id integer primary key, name text default 'yang'"]);
  lite.createIndex("hello", ["name"]);
  Pragma p = lite.PRAGMA;

  p.query("index_xinfo('hello_name')").dump();
  // println(p.table_list());
// println(p.index_list('hello'));
  lite.close();
}
