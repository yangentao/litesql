part of 'sql.dart';

extension ResultSetToQueryResultExt on ResultSet {
  QueryResult get queryResult {
    ResultMeta meta = ResultMeta(columnNames.mapList((e) => ColumnMeta(label: e)));
    return QueryResult(rows, meta: meta, rawResult: this);
  }
}

final QueryResult emptyResult = QueryResult([], meta: ResultMeta([]));

class QueryResult extends UnmodifiableListView<List<Object?>> {
  // ignore: unused_field
  final int _affectedRows;
  final ResultMeta meta;
  final Object? rawResult;

  int labelToIndex(String label) => meta.labelToIndex(label);

  QueryResult(List<List<Object?>> super.source, {required this.meta, this.rawResult, int affectedRows = 0}) : _affectedRows = affectedRows;
}

class ResultMeta {
  final List<ColumnMeta> columns;
  final Map<String, int> labelIndexMap;

  ResultMeta(this.columns) : labelIndexMap = Map.fromEntries(columns.mapIndex((i, e) => MapEntry(e.label, i)));

  int get length => columns.length;

  int labelToIndex(String label) => labelIndexMap[label] ?? errorSQL("NO label found");

  @override
  String toString() {
    return columns.map((e) => e.label).toString();
  }
}

class ColumnMeta {
  final String label;

  // ignore: unused_field
  final int _typeId;

  ColumnMeta({required this.label, int typeId = 0}) : _typeId = typeId;

  @override
  String toString() {
    return label;
  }
}

//------------------
class RowData extends UnmodifiableListView<Object?> {
  final ResultMeta meta;

  RowData(super.source, {required this.meta});

  int labelToIndex(String label) => meta.labelToIndex(label);

  Object? named(String label) => this[labelToIndex(label)];

  T? get<T>(Object key) {
    if (key case int n) return getOr(n) as T?;
    return named(key.toString()) as T?;
  }

  AnyMap toMap() => AnyMap.fromEntries(this.mapIndex((i, e) => MapEntry(meta.columns[i].label, e)));

  @override
  String toString() {
    return toMap().toString();
  }
}

class StepCursor implements Iterator<RowData> {
  IteratingCursor cursor;
  PreparedStatement statement;
  ResultMeta meta;

  StepCursor({required this.cursor, required this.statement}) : meta = ResultMeta(cursor.columnNames.mapList((e) => ColumnMeta(label: e)));

  List<String?> get tableNames => cursor.tableNames ?? [];

  @override
  RowData get current => RowData(cursor.current.values, meta: meta);

  @override
  bool moveNext() {
    bool ok = cursor.moveNext();
    if (!ok) {
      statement.close();
    }
    return ok;
  }

  void close() {
    statement.close();
  }
}

// mapXXX, valueXXX, modelXXX
extension QueryResultExt on QueryResult {
  int get columnCount => meta.columns.length;

  // value
  /// key is  int index , OR String key
  T? firstValue<T>([Object col = 0]) {
    if (col case int n) return this.firstOrNull?[n] as T?;
    return this.firstOrNull?[labelToIndex(col.toString())] as T?;
  }

  T? oneValue<T>({required int row, Object col = 0}) {
    if (col case int n) return this[row][n] as T?;
    return this[row][labelToIndex(col.toString())] as T?;
  }

  /// col is  int index , OR String key
  List<T> listValues<T>([Object col = 0]) {
    if (col case int n) {
      return this.mapList((e) => e[n] as T);
    }
    int n = labelToIndex(col.toString());
    return this.mapList((e) => e[n] as T);
  }

  // map
  AnyMap? firstMap() => this.isEmpty ? null : oneMap(0);

  AnyMap oneMap(int row) => AnyMap.fromEntries(this[row].mapIndex((i, e) => MapEntry(meta.columns[i].label, e)));

  List<AnyMap> listMaps() => this.mapIndex((i, _) => oneMap(i));

  // model
  T? firstModel<T>(ModelCreator<T> creator) => firstMap()?.let(creator);

  T oneModel<T>(ModelCreator<T> creator, {required int row}) => creator(this.oneMap(row));

  List<T> listModels<T>(ModelCreator<T> creator) => listMaps().mapList(creator);

  // row
  RowData? firstRow() => this.isEmpty ? null : oneRow(0);

  RowData oneRow(int row) => RowData(this[row], meta: meta);

  List<RowData> listRows() => this.mapList((e) => RowData(e, meta: meta));

  List<R> mapRow<R>(R Function(RowData) callback) => this.mapList((e) => callback(RowData(e, meta: meta)));

  void dump() {
    if (this.isEmpty) {
      logSQL.d("[empty]");
    } else {
      for (AnyMap row in this.listMaps()) {
        logSQL.d(row);
      }
    }
  }
}
