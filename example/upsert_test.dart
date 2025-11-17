import 'package:litesql/litesql.dart';
import 'package:println/println.dart';
import 'package:sqlite3/sqlite3.dart';

void main2() async {
  LiteSQL lite = LiteSQL.openMemory();
  lite.lastInsertRowId = 8;
  // clearLastRowId(lite.database.handle, 2);
  println("last insert row: ", lite.lastInsertRowId);
}

void main() async {
  LiteSQL lite = LiteSQL.openMemory();
  println("version: ", LiteSQL.version.versionNumber);
  lite.execute("CREATE TABLE stu(id INTEGER PRIMARY KEY AUTOINCREMENT, name text)");

  ResultSet r1 = lite.rawQuery("INSERT INTO stu(name) values('yang')  RETURNING id");
  println("lastRowID: ", lite.lastInsertRowId);
  r1.dump();

  lite.lastInsertRowId = 0;
  ResultSet r2 = lite.rawQuery("INSERT INTO stu(id, name) values(1, 'entao') ON CONFLICT(id) DO UPDATE SET name = 'entao' RETURNING id");
  println("upsert lastRowID: ", lite.lastInsertRowId);
  r2.dump();

  ResultSet rs = lite.rawQuery("SELECT * FROM stu");
  rs.dump();

  lite.close();
}

// late final _sqlite3_last_insert_rowidPtr = _lookup<ffi.NativeFunction<ffi.Int64 Function(ffi.Pointer<imp$1.sqlite3>)>>('sqlite3_last_insert_rowid');
// late final _sqlite3_last_insert_rowid = _sqlite3_last_insert_rowidPtr.asFunction<int Function(ffi.Pointer<imp$1.sqlite3>)>();
