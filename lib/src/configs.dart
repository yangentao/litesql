part of 'sql.dart';

class Configs extends JsonModel {
  Configs(super.jsonValue);

  static Configs create() {
    return Configs(JsonValue.object());
  }

  String get key => KEY.get(this);

  set key(String value) => KEY.set(this, value);

  String? get valueS => VALUE_S.get(this);

  set valueS(String? value) => VALUE_S.set(this, value);

  int? get valueN => VALUE_N.get(this);

  set valueN(int? value) => VALUE_N.set(this, value);

  double? get valueF => VALUE_F.get(this);

  set valueF(double? value) => VALUE_F.set(this, value);

  static FieldSQL KEY = FieldSQL.text(name: "key_", primaryKey: true);
  static FieldSQL VALUE_S = FieldSQL.text(name: "values_");
  static FieldSQL VALUE_N = FieldSQL.integer(name: "valuen_");
  static FieldSQL VALUE_F = FieldSQL.integer(name: "valuef_");

  static TableSQL TABLE = TableSQL("configs", [KEY, VALUE_S, VALUE_N, VALUE_F]);

  static ConfigsTable use(LiteSQL lite) {
    return ConfigsTable(lite: lite, table: TABLE);
  }
}

class ConfigsTable extends SingleTable {
  ConfigsTable({required super.table, required super.lite});

  void putString(String key, String value) {
    upsert([Configs.KEY >> key, Configs.VALUE_S >> value]);
  }

  void putInt(String key, int value) {
    upsert([Configs.KEY >> key, Configs.VALUE_N >> value]);
  }

  void putDouble(String key, double value) {
    upsert([Configs.KEY >> key, Configs.VALUE_F >> value]);
  }

  String getString(String key) {
    return this.oneValue(Configs.VALUE_S, where: Configs.KEY.EQ(key));
  }

  int getInt(String key) {
    return this.oneValue(Configs.VALUE_N, where: Configs.KEY.EQ(key));
  }

  double getDouble(String key) {
    return this.oneValue(Configs.VALUE_F, where: Configs.KEY.EQ(key));
  }
}
