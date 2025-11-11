part of 'sql.dart';

enum Configs with TableColumn<Configs> {
  name(ColumnSQL.text(primaryKey: true)),
  nValue(ColumnSQL.integer()),
  fValue(ColumnSQL.real()),
  sValue(ColumnSQL.text());

  const Configs(this.column);

  @override
  final ColumnSQL column;

  @override
  List<Configs> get columns => Configs.values;
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

  static void putString(String name, String value) {
    From(Configs).upsert([Configs.name >> name, Configs.sValue >> value]);
  }

  static void putInt(String name, int value) {
    From(Configs).upsert([Configs.name >> name, Configs.nValue >> value]);
  }

  static void putDouble(String name, double value) {
    From(Configs).upsert([Configs.name >> name, Configs.fValue >> value]);
  }

  static String? getString(String name) {
    return From(Configs).oneValue(Configs.sValue, where: Configs.name.EQ(name));
  }

  static int? getInt(String name) {
    return From(Configs).oneValue(Configs.nValue, where: Configs.name.EQ(name));
  }

  static double? getDouble(String name) {
    return From(Configs).oneValue(Configs.fValue, where: Configs.name.EQ(name));
  }
}
