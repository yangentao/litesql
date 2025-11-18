part of '../sql.dart';

extension ETableSQLExt<T extends TableColumn<T>> on TableColumn<T> {
  String MAX() {
    return "MAX($fullname)";
  }

  String MIN() {
    return "MIN($fullname)";
  }
}
