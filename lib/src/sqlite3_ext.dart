part of 'sql.dart';

extension ResultSetExt on ResultSet {
  dynamic get firstRowFirstColumn {
    return this.firstOrNull?.firstColumn;
  }

  MapSQL? get firstRow {
    return this.firstOrNull?.mapSQL;
  }

  List<MapSQL> get listRows {
    return this.mapList((e) => e.mapSQL);
  }

  void dump() {
    if (this.isEmpty) {
      println("[empty]");
      return;
    }
    for (Row r in this) {
      String s = r.entries.map((e) => "${e.key}: ${e.value}").join(", ");
      println(s);
    }
  }
}

extension RowExt on Row {
  MapSQL get mapSQL {
    MapSQL map = {};
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
