part of 'sql.dart';

extension ResultSetExt on ResultSet {
  int get columnCount => columnNames.length;

  int labelToIndex(String label) => this.columnNames.indexOf(label);

  // value
  /// key is  int index , OR String key
  T? firstValue<T>([Object col = 0]) {
    if (col case int n) return this.rows.firstOrNull?[n] as T?;
    return this.rows.firstOrNull?[labelToIndex(col.toString())] as T?;
  }

  T? oneValue<T>({required int row, Object col = 0}) {
    if (col case int n) return this.rows[row][n] as T?;
    return this.rows[row][labelToIndex(col.toString())] as T?;
  }

  /// col is  int index , OR String key
  List<T> listValues<T>([Object col = 0]) {
    if (col case int n) {
      return this.mapList((e) => e[n] as T);
    }
    int n = labelToIndex(col.toString());
    return this.mapList((e) => e[n] as T);
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
  @Deprecated("remove it")
  AnyMap get mapSQL {
    AnyMap map = {};
    for (String k in this.keys) {
      map[k] = this[k];
    }
    return map;
  }

  @Deprecated("remove it")
  dynamic get firstColumn {
    return this.columnAt(0);
  }

  @Deprecated("remove it")
  dynamic get secondColumn {
    return this.columnAt(1);
  }

  List<String> get columns => this.keys;

  int labelToIndex(String label) => this.columns.indexOf(label);

  Object? named(String label) => this[label];

  Object? get(Object key) {
    if (key case int n) {
      if (n >= 0 && n < values.length) {
        return columnAt(n);
      } else {
        return null;
      }
    }
    return this[key.toString()];
  }

  AnyMap toMap() {
    AnyMap map = {};
    AnyList values = this.values;
    List<String> labels = this.keys;
    for (int i = 0; i < values.length; ++i) {
      map[labels[i]] = values[i];
    }
    return map;
  }
}
