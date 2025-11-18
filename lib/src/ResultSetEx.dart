part of 'sql.dart';

extension ResultSetExt on ResultSet {
  int get columnCount => columnNames.length;

  Object? valueAt({required int row, required int col}) => this.rows[row][col];

  Object? valueNamed({required int row, required String col}) => this[row][col];

  dynamic firstValue() => this.firstOrNull?.columnAt(0);

  List<T> allValues<T>({int col = 0}) => this.mapList((e) => e.columnAt(col));

  AnyMap rowAt({required int index}) => this[index].mapSQL;

  AnyMap? firstRow() => this.firstOrNull?.mapSQL;

  List<AnyMap> allRows() => this.mapList((e) => e.mapSQL);

  T modelAt<T>(ModelCreator<T> creator, {required int row}) => this.elementAt(row).let((e) => creator(e));

  T? firstModel<T>(ModelCreator<T> creator) => firstRow()?.let((e) => creator(e));

  List<T> allModels<T>(ModelCreator<T> creator) => allRows().mapList((e) => creator(e));

  void dump() {
    if (this.isEmpty) {
      logSQL.d("[empty]");
      return;
    }
    for (Row r in this) {
      logSQL.d(r.mapSQL);
    }
  }
}

extension RowExt on Row {
  AnyMap get mapSQL {
    AnyMap map = {};
    for (String k in this.keys) {
      map[k] = this[k];
    }
    return map;
  }

  dynamic get firstColumn {
    return this.columnAt(0);
  }

  dynamic get secondColumn {
    return this.columnAt(1);
  }
}
