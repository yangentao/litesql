part of 'sql.dart';

class TableSQL {
  final String name;
  final List<FieldSQL> fields;
  final String nameSQL;

  TableSQL(this.name, this.fields) : nameSQL = name.escapeSQL {
    for (var e in fields) {
      e.table = this;
    }
  }
}

extension FieldSQLJoinOnExt on FieldSQL {
  String JOIN(TableSQL other, {required String on}) {
    return "$nameSQL JOIN ${other.nameSQL} ON $on";
  }

  String LEFT_JOIN(TableSQL other, {required String on}) {
    return "$nameSQL LEFT JOIN ${other.nameSQL} ON $on";
  }

  String RIGHT_JOIN(TableSQL other, {required String on}) {
    return "$nameSQL RIGHT JOIN ${other.nameSQL} ON $on";
  }

  String FULL_JOIN(TableSQL other, {required String on}) {
    return "$nameSQL FULL JOIN ${other.nameSQL} ON $on";
  }
}
