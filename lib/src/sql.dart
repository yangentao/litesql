import 'dart:collection';
import 'dart:convert';
import 'dart:core';
import 'dart:ffi' as ffi;
import 'dart:math';
import 'dart:typed_data';

import 'package:entao_dutil/entao_dutil.dart';
import 'package:entao_log/entao_log.dart';
import 'package:sqlite3/sqlite3.dart';

import 'sqlite3_x.dart' as xsql;

part 'ColumnSQL.dart';
part 'EnumTable.dart';
part 'FieldProto.dart';
part 'LiteInserts.dart';
part 'LiteQuery.dart';
part 'LiteSQL.dart';
part 'LiteUpdate.dart';
part 'Migrate.dart';
part 'MigrateETable.dart';
part 'SingleTable.dart';
part 'TableColumn.dart';
part 'TableColumnExt.dart';
part 'TableModel.dart';
part 'TableProto.dart';
part 'configs.dart';
part 'sql_utils.dart';
part 'sqlite3_ext.dart';
part 'wheres.dart';

typedef MapSQL = Map<String, dynamic>;
typedef BlobSQL = Uint8List;

typedef ModelCreator<T> = T Function(MapSQL);

TagLog logSQL = TagLog("SQL");

final class Returning {
  final List<String> columns;
  List<MapSQL> values = [];

  Returning([this.columns = const ["*"]]);
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
  if (model is TableModel) return model[name];
  if (model is Map<String, dynamic>) return _checkNum(model[name]);
  if (model is MapModel) return _checkNum(model[name].value);
  throw SQLException(" get model value failed, unknown container: $model, column: $name.");
}

void _setModelValue(Object model, String key, dynamic value) {
  if (model is TableModel) {
    model[key] = value;
  } else if (model is Map<String, dynamic>) {
    model[key] = value;
  } else if (model is MapModel) {
    model[key] = value;
  } else {
    throw SQLException("set value failed, unknown container:$model, tableColumn:$key.");
  }
}
