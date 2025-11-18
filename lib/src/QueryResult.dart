part of 'sql.dart';

extension ResultSetExt on ResultSet {
  QueryResult get result => QueryResult(this);

  dynamic get oneValue {
    return this.firstOrNull?.firstColumn;
  }

  AnyMap? get firstRow {
    return this.firstOrNull?.mapSQL;
  }

  List<AnyMap> get listRows {
    return this.mapList((e) => e.mapSQL);
  }

  void dump() {
    if (this.isEmpty) {
      logSQL.d("[empty]");
      return;
    }
    for (Row r in this) {
      String s = r.entries.map((e) => "${e.key}: ${e.value}").join(", ");
      logSQL.d(s);
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

class QueryResult with ListMixin<AnyMap> {
  ResultSet resultSet;

  QueryResult(this.resultSet);

  int get columnCount => resultSet.columnNames.length;

  List<String> get columnNames => resultSet.columnNames;

  Object? valueAt(int row, int col) => resultSet.rows[row][col];

  Object? valueNamed(int row, String name) => resultSet[row][name];

  AnyMap rowAt(int index) => resultSet[index].mapSQL;

  AnyMap? get firstRow => resultSet.firstOrNull?.mapSQL;

  List<AnyMap> get listRows => resultSet.mapList((e) => e.mapSQL);

  dynamic get firstValue => resultSet.firstOrNull?.columnAt(0);

  List<T> listValues<T>() => resultSet.mapList((e) => e.columnAt(0));

  T modelAt<T>(int index, ModelCreator<T> creator) => resultSet.elementAt(index).let((e) => creator(e));

  T? firstModel<T>(ModelCreator<T> creator) => firstRow?.let((e) => creator(e));

  List<T> listModel<T>(ModelCreator<T> creator) => listRows.mapList((e) => creator(e));

  @override
  int get length => resultSet.length;

  @override
  AnyMap operator [](int index) {
    return rowAt(index);
  }

  @override
  void operator []=(int index, AnyMap value) {
    errorSQL("QueryResult is inmutable");
  }

  @override
  set length(int newLength) {
    errorSQL("QueryResult is inmutable");
  }

  void dump() {
    if (this.isEmpty) {
      logSQL.d("[empty]");
      return;
    }
    for (AnyMap r in this) {
      logSQL.d(json.encode(r));
    }
  }
}
