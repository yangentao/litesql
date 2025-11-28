import 'package:entao_dutil/entao_dutil.dart';
import 'package:litesql/litesql.dart';
import 'package:println/println.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  LiteSQL lite = LiteSQL.openMemory();
  lite.createTable("ta", ["id INTEGER", "name TEXT", "tm INTEGER"], constraints: ["PRIMARY KEY(id)"]);
  lite.insert("ta", values: ["id" >> 1, "name" >> "yang1", "tm" >> 100]);
  lite.insert("ta", values: ["id" >> 2, "name" >> "yang2", "tm" >> 200]);
  lite.insert("ta", values: ["id" >> 3, "name" >> "yang2", "tm" >> 300]);

  ResultSet rs = lite.rawQuery("SELECT ta.id, ta.name, MAX(ta.tm) FROM ta GROUP BY ta.name ORDER BY ta.tm DESC");
  for (Row row in rs) {
    println(row);
  }
  lite.close();
}
