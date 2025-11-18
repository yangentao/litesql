part of '../sql.dart';

class Express {
  final SpaceBuffer buffer;

  final AnyList args;

  Express(String express, {AnyList? args}) : buffer = SpaceBuffer(express), this.args = args ?? [];

  String get sql => buffer.toString();

  bool get isEmpty => buffer.isEmpty;

  bool get isNotEmpty => buffer.isNotEmpty;

  Express get braced => Express("($sql)", args: this.args);

  ResultSet query(LiteSQL lite) => lite.rawQuery(this.sql, args);

  @override
  String toString() {
    return sql;
  }

  // Express OR String
  Express operator +(Object other) {
    switch (other) {
      case String s:
        return Express("$sql $s");
      case Express ex:
        return Express("$sql ${ex.sql}", args: args + other.args);
    }
    errorSQL("Operator '+' only support Express OR String");
  }

  Express operator <<(Object other) {
    switch (other) {
      case String s:
        return this.addText(s);
      case num n:
        return this.addText(n.toString());
      case Express ex:
        return this.addExpress(ex);
      case TableColumn c:
        return this.addText(c.fullname);
      case Type t:
        return this.addText(TableProto.of(t).nameSQL);
      case TableProto t:
        return this.addText(t.nameSQL);
      case AnyList ls:
        AnyList ls2 = ls.filter((e) => e != null);
        for (int i = 0; i < ls2.length; ++i) {
          if (i != 0) this << ",";
          this << ls[i];
        }
        return this;
    }
    errorSQL("Operator '<<' only support String/Express/TableColumn/Type/FieldProto/List<dynamic>");
  }

  Express addExpress(Express other) {
    this.buffer << other.sql;
    this.args.addAll(other.args);
    return this;
  }

  Express addText(String clause) {
    this.buffer << clause;
    return this;
  }

  Express addArgs(AnyList args) {
    this.args.addAll(args);
    return this;
  }
}
