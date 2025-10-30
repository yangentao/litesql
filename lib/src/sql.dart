import 'dart:collection';
import 'dart:convert';
import 'dart:core';
import 'dart:math';
import 'dart:typed_data';

import 'package:entao_dutil/entao_dutil.dart';
import 'package:entao_log/entao_log.dart';
import 'package:println/println.dart';
import 'package:sqlite3/sqlite3.dart';

part 'ColumnSQL.dart';
part 'TableColumn.dart';
part 'EnumTable.dart';
part 'FieldProto.dart';
part 'LiteSQL.dart';
part 'Migrate.dart';
part 'MigrateETable.dart';
part 'TableModel.dart';
part 'SingleTable.dart';
part 'TableProto.dart';
part 'WhereExtends.dart';
part 'configs.dart';
part 'sql_utils.dart';
part 'sqlite3_ext.dart';
part 'wheres.dart';

typedef MapSQL = Map<String, dynamic>;
typedef BlobSQL = Uint8List;

typedef ModelCreator<T> = T Function(MapSQL);

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
