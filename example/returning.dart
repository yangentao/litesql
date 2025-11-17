import 'package:litesql/litesql.dart';
import 'package:println/println.dart';
import 'package:sqlite3/sqlite3.dart';

// extension on String {
//   (String, dynamic) operator &(dynamic value) {
//     return (this, value);
//   }
// }

void main() async {
  LiteSQL lite = LiteSQL.openMemory();
  println("version: ", LiteSQL.version.versionNumber);
  lite.execute("CREATE TABLE stu(id INTEGER PRIMARY KEY , name text)");

  Returning rr = Returning(["*"]);
  List<int> idList = lite.insertMulti("stu", ["name"], [['yang'], ['en'], ['tao']], returning: rr);

  println("idList: ", idList); // [1, 2, 3]
  println("returning: ", rr.returnRows); // [{id: 1, name: yang}, {id: 2, name: en}, {id: 3, name: tao}]

  ResultSet rs = lite.rawQuery("SELECT * FROM stu");
  rs.dump();
  lite.close();
}

// late final _sqlite3_last_insert_rowidPtr = _lookup<ffi.NativeFunction<ffi.Int64 Function(ffi.Pointer<imp$1.sqlite3>)>>('sqlite3_last_insert_rowid');
// late final _sqlite3_last_insert_rowid = _sqlite3_last_insert_rowidPtr.asFunction<int Function(ffi.Pointer<imp$1.sqlite3>)>();
