part of 'sql.dart';

extension ResultSetExtResult on ResultSet {
  QueryResult get result => QueryResult(this);
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
