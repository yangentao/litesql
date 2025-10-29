import 'dart:convert';
import 'dart:core';
import 'dart:math';
import 'dart:typed_data';

import 'package:entao_dutil/entao_dutil.dart';
import 'package:entao_log/entao_log.dart';
import 'package:println/println.dart';
import 'package:sqlite3/sqlite3.dart';

part 'configs.dart';
part 'EColumn.dart';
part 'FieldSQL.dart';
part 'LiteSQL.dart';
part 'ModelSQL.dart';
part 'sql_utils.dart';
part 'sqlite3_ext.dart';
part 'TableSQL.dart';
part 'wheres.dart';
part 'ETable.dart';
part 'LiteSQLExtends.dart';
part 'MigrateETable.dart';
part 'Migrate.dart';

typedef MapSQL = Map<String, dynamic>;
typedef BlobSQL = Uint8List;

typedef ModelCreator<T> = T Function(MapSQL);

const List<Type> typesSQL = [bool, int, double, String, BlobSQL];

class SQLException implements Exception {
  String message;
  StackTrace stackTrace;

  SQLException(this.message) : stackTrace = StackTrace.current;

  @override
  String toString() {
    return "SQLException: $message .  $stackTrace";
  }
}

Never errorSQL(String message) {
  throw SQLException(message);
}
