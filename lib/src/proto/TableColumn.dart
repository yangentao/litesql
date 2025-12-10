part of '../sql.dart';

/// don't use 'name', use 'columnName',  enum's name maybe renamed.
mixin TableColumn on Enum {
  ColumnProto get proto;

  String get tableName => tableProto.name;

  String get columnName => proto.name ?? this.name;

  String get nameSQL {
    String? s = _getColumnProperty(this, "nameSQL");
    if (s != null) return s;
    String n = columnName.escapeSQL;
    _setColumnProperty(this, "nameSQL", n);
    return n;
  }

  String get fullname {
    String? s = _getColumnProperty(this, "fullname");
    if (s != null) return s;
    String n = "${tableName.escapeSQL}.$nameSQL";
    _setColumnProperty(this, "fullname", n);
    return n;
  }

  TableProto get tableProto => _getColumnProperty(this, "tableProto");

  set _tableProto(TableProto p) {
    _setColumnProperty(this, "tableProto", p);
  }

  V? get<V>(Object? container) {
    if (container == null) return null;
    return _getModelValue(container, this.columnName);
  }

  void set(Object model, dynamic value) {
    _setModelValue(model, this.columnName, value);
  }

  MapEntry<TableColumn, dynamic> operator >>(dynamic value) {
    return MapEntry<TableColumn, dynamic>(this, proto.encode(value));
  }
}

final Map<Enum, AnyMap> _columnPropMap = {};

V? _getColumnProperty<V>(TableColumn column, String key) {
  return _columnPropMap[column]?[key];
}

void _setColumnProperty(TableColumn column, String key, dynamic value) {
  AnyMap? map = _columnPropMap[column];
  if (map != null) {
    if (value == null) {
      map.remove(key);
    } else {
      map[key] = value;
    }
  } else {
    if (value != null) {
      _columnPropMap[column] = {key: value};
    }
  }
}
