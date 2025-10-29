part of 'sql.dart';

class Configs extends ModelSQL {
  Configs(super.mapSQL);

  Configs.empty() : super.empty();

  String get key => KEY.get(this);

  set key(String value) => KEY.set(this, value);

  String? get sValue => SVALUE.get(this);

  set sValue(String? value) => SVALUE.set(this, value);

  int? get nValue => NVALUE.get(this);

  set nValue(int? value) => NVALUE.set(this, value);

  double? get fValue => FVALUE.get(this);

  set fValue(double? value) => FVALUE.set(this, value);

  static FieldSQL KEY = FieldSQL.text(name: "key_", primaryKey: true);
  static FieldSQL SVALUE = FieldSQL.text(name: "svalue");
  static FieldSQL NVALUE = FieldSQL.integer(name: "nvalue");
  static FieldSQL FVALUE = FieldSQL.real(name: "fvalue");

  static TableSQL TABLE = TableSQL("configs", [KEY, SVALUE, NVALUE, FVALUE]);

  static ConfigsTable use(LiteSQL lite) {
    return ConfigsTable(lite: lite, table: TABLE);
  }
}

class ConfigsTable extends SingleTable {
  ConfigsTable({required super.table, required super.lite});

  void putString(String key, String value) {
    upsert([Configs.KEY >> key, Configs.SVALUE >> value]);
  }

  void putInt(String key, int value) {
    upsert([Configs.KEY >> key, Configs.NVALUE >> value]);
  }

  void putDouble(String key, double value) {
    upsert([Configs.KEY >> key, Configs.FVALUE >> value]);
  }

  String getString(String key) {
    return this.oneValue(Configs.SVALUE, where: Configs.KEY.EQ(key));
  }

  int getInt(String key) {
    return this.oneValue(Configs.NVALUE, where: Configs.KEY.EQ(key));
  }

  double getDouble(String key) {
    return this.oneValue(Configs.FVALUE, where: Configs.KEY.EQ(key));
  }
}
