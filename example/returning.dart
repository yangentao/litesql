import 'package:entao_dutil/entao_dutil.dart';
import 'package:litesql/litesql.dart';
import 'package:println/println.dart';
import 'package:sqlite3/sqlite3.dart';

void main() async {
  LiteSQL lite = LiteSQL.openMemory();
  println("version: ", LiteSQL.version.versionNumber);
  lite.execute("CREATE TABLE stu(id INTEGER PRIMARY KEY , name text)");

  Returning rr = Returning(["id"]);
  lite.insertRowsReturning("stu", [
    ["name" >> 'yang'],
    ["name" >> 'en'],
    ["name" >> 'tao'],
  ], returning: rr);

  for (var row in rr.values) {
    println(row);
  }
  println("update rows: ",lite.updatedRows);

  ResultSet rs = lite.rawQuery("SELECT * FROM stu");
  rs.dump();

  lite.close();
}

// late final _sqlite3_last_insert_rowidPtr = _lookup<ffi.NativeFunction<ffi.Int64 Function(ffi.Pointer<imp$1.sqlite3>)>>('sqlite3_last_insert_rowid');
// late final _sqlite3_last_insert_rowid = _sqlite3_last_insert_rowidPtr.asFunction<int Function(ffi.Pointer<imp$1.sqlite3>)>();
