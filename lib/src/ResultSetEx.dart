part of 'sql.dart';

extension ResultSetExt on ResultSet {
  int get columnCount => columnNames.length;

  int labelToIndex(String label) => this.columnNames.indexOf(label);

  Object? valueAt({required int row, required int col}) => this.rows[row][col];

  Object? valueNamed({required int row, required String col}) => this[row][col];

  dynamic firstValue() => this.firstOrNull?.columnAt(0);

  List<T> listValues<T>([Object col = 0]) {
    if (col case int n) return this.mapList((e) => e.columnAt(n));
    int n = labelToIndex(col.toString());
    return this.mapList((e) => e.columnAt(n));
  }

  AnyMap rowAt({required int index}) => this[index].mapSQL;

  AnyMap? firstRow() => this.firstOrNull?.mapSQL;

  List<AnyMap> listRows() => this.mapList((e) => e.mapSQL);

  T modelAt<T>(ModelCreator<T> creator, {required int row}) => this.elementAt(row).let((e) => creator(e));

  T? firstModel<T>(ModelCreator<T> creator) => firstRow()?.let((e) => creator(e));

  List<T> listModels<T>(ModelCreator<T> creator) => listRows().mapList((e) => creator(e));

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
