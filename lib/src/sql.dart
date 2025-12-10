import 'dart:collection';
import 'dart:convert';
import 'dart:core';
import 'dart:ffi' as ffi;
import 'dart:math';
import 'dart:typed_data';

import 'package:entao_dutil/entao_dutil.dart';
import 'package:entao_log/entao_log.dart';
import 'package:sqlite3/sqlite3.dart';

import 'sqlite3_ffi.dart' as xsql;

part 'LiteExt.dart';
part 'LiteSQL.dart';
part 'SpaceBuffer.dart';
part 'clause/clauses.dart';
part 'clause/express.dart';
part 'clause/ext.dart';
part 'clause/func.dart';
part 'clause/func_win.dart';
part 'clause/joins.dart';
part 'clause/where.dart';
part 'configs.dart';
part 'pragma.dart';
part 'proto/TableColumn.dart';
part 'proto/TableModel.dart';
part 'proto/TableOf.dart';
part 'proto/TableProto.dart';
part 'proto/migrator.dart';
part 'proto/types.dart';
part 'result.dart';
part 'sql_utils.dart';

TagLog logSQL = TagLog("SQL");

const List<String> ALL_COLUMNS = ["*"];

typedef BlobSQL = Uint8List;

typedef ModelCreator<T> = T Function(AnyMap);
typedef ColumnValue<T extends Object> = MapEntry<T, dynamic>;

String _returningClause(List<Object>? columns) {
  if (columns == null || columns.isEmpty) return "";
  return " RETURNING ${columns.join(", ")}";
}

enum InsertOption {
  abort("ABORT"),
  fail("FAIL"),
  ignore("IGNORE"),
  replace("REPLACE"),
  rollback("ROLLBACK");

  const InsertOption(this.conflict);

  final String conflict;
}

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

bool _canSave(dynamic item) {
  return item is TableModel || item is Map<String, dynamic> || item is MapModel;
}

T? _getModelValue<T>(Object model, String name) {
  switch (model) {
    case TableModel m:
      return m[name];
    case MapModel m:
      return m[name];
    case AnyMap m:
      return _checkNum(m[name]);
    default:
      errorSQL(" get model value failed, unknown container: $model, column: $name.");
  }
}

void _setModelValue(Object model, String key, dynamic value) {
  switch (model) {
    case TableModel m:
      m[key] = value;
    case MapModel m:
      m[key] = value;
    case AnyMap m:
      m[key] = value;
    default:
      errorSQL("set value failed, unknown container:$model, tableColumn:$key.");
  }
}

String _makeIndexName(String table, List<String> fields) {
  var ls = fields.sorted(null);
  return "${table}_${ls.join("_")}";
}
