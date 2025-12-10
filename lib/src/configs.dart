part of 'sql.dart';

enum Configs with TableColumn  {
  name(TEXT(primaryKey: true)),
  nValue(INTEGER()),
  fValue(REAL()),
  sValue(TEXT());

  const Configs(this.proto);

  @override
  final ColumnProto proto;

}

class MConfigs extends TableModel<Configs> {
  MConfigs(super.model);

  String get name => Configs.name.get(this);

  set name(String value) => Configs.name.set(this, value);

  String? get sValue => Configs.sValue.get(this);

  set sValue(String? value) => Configs.sValue.set(this, value);

  int? get nValue => Configs.nValue.get(this);

  set nValue(int? value) => Configs.nValue.set(this, value);

  double? get fValue => Configs.fValue.get(this);

  set fValue(double? value) => Configs.fValue.set(this, value);

  static void remove(String name) {
    table.deleteBy(key: name);
  }

  static void putString(String name, String value) {
    table.upsert(values: [Configs.name >> name, Configs.sValue >> value]);
  }

  static void putInt(String name, int value) {
    table.upsert(values: [Configs.name >> name, Configs.nValue >> value]);
  }

  static void putDouble(String name, double value) {
    table.upsert(values: [Configs.name >> name, Configs.fValue >> value]);
  }

  static String? getString(String name) {
    return table.oneValue(column: Configs.sValue, where: Configs.name.EQ(name));
  }

  static int? getInt(String name) {
    return table.oneValue(column: Configs.nValue, where: Configs.name.EQ(name));
  }

  static double? getDouble(String name) {
    return table.oneValue(column: Configs.fValue, where: Configs.name.EQ(name));
  }

  static final table = TableOf(MConfigs.new);
}
