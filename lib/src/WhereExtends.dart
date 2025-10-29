part of 'sql.dart';

extension WhereEnum<T> on ETable<T> {
  Where EQ(dynamic value) {
    return Where(this.nameSQL, OpSQL.eq, value);
  }
}
