part of 'sql.dart';

extension WhereEnum<T> on TableColumn<T> {
  Where EQ(dynamic value) {
    return Where(this.nameSQL, OpSQL.eq, value);
  }

  Where IN(ArgSQL values) {
    var a = values.map((e) => "?").join(",");
    return Where.raw("${this.nameSQL} IN ($a) ", values);
  }

  Where NE(dynamic value) {
    return Where(nameSQL, OpSQL.ne, value);
  }

  Where GE(dynamic value) {
    return Where(nameSQL, OpSQL.ge, value);
  }

  Where LE(dynamic value) {
    return Where(nameSQL, OpSQL.le, value);
  }

  Where GT(dynamic value) {
    return Where(nameSQL, OpSQL.gt, value);
  }

  Where LT(dynamic value) {
    return Where(nameSQL, OpSQL.lt, value);
  }

  Where LIKE(dynamic value) {
    return Where(nameSQL, OpSQL.like, value);
  }

  String get ASC => "$nameSQL ASC";

  String get DESC => "$nameSQL DESC";
}
