part of '../sql.dart';

extension StringExpressExt on String {
  Express get express => Express(this);

  String AS(String alias) => "$this AS $alias";

  String get ASC => "${this.escapeSQL} ASC";

  String get DESC => "${this.escapeSQL} DESC";
}

extension TableColumnExpresExt<T extends TableColumn<T>> on TableColumn<T> {
  String AS(String alias) => "$fullname AS $alias";

  String get ASC => "$fullname ASC";

  String get DESC => "$fullname DESC";
}

extension  on Type {
  TableProto get proto => _requireTableProto(this);
}



extension ListJoinMapEx<T> on List<T> {
  String joinMap(String sep, [String Function(T)? tranform]) {
    if (tranform == null) return join(sep);
    return this.map(tranform).join(sep);
  }
}
