part of '../sql.dart';

AnyList ls = [];

class Express {
  final SpaceBuffer buffer;

  final AnyList args;

  Express(String express, {AnyList? args}) : buffer = SpaceBuffer.text(express), this.args = args ?? [];

  String get sql => buffer.toString();

  bool get isEmpty => buffer.isEmpty;

  bool get isNotEmpty => buffer.isNotEmpty;

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

  // Express OR String
  Express operator <<(Object other) {
    switch (other) {
      case String s:
        return this.addText(s);
      case Express ex:
        return this.addExpress(ex);
    }
    errorSQL("Operator '+' only support Express OR String");
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

extension type SpaceBuffer(StringBuffer buffer) {
  SpaceBuffer.text([String s = ""]) : this(StringBuffer(s));

  bool get isEmpty => buffer.isEmpty;

  bool get isNotEmpty => !isEmpty;

  int get length => buffer.length;

  SpaceBuffer get space {
    buffer.write(" ");
    return this;
  }

  SpaceBuffer get newLine {
    buffer.writeln("");
    return this;
  }

  SpaceBuffer operator <<(String s) {
    return add(s);
  }

  SpaceBuffer add(String s) {
    buffer.write(" ");
    buffer.write(s);
    return this;
  }

  SpaceBuffer addAll(List<String> ls) {
    buffer.write(" ");
    buffer.write(ls.join(" "));
    return this;
  }

  SpaceBuffer addLine(String s) {
    buffer.write(" ");
    buffer.writeln(s);
    return this;
  }
}
