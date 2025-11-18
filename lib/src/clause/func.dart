part of '../sql.dart';

Express AVG(Object express) {
  return ExpressFunc("AVG", [express]);
}

Express SUM(Object express) {
  return ExpressFunc("SUM", [express]);
}

Express TOTAL(Object express) {
  return ExpressFunc("TOTAL", [express]);
}

Express MIN(Object express) {
  return ExpressFunc("MIN", [express]);
}

Express MAX(Object express) {
  return ExpressFunc("MAX", [express]);
}

Express MEDIAN(Object express) {
  return ExpressFunc("MEDIAN", [express]);
}

Express COUNT(Object express) {
  return ExpressFunc("COUNT", [express]);
}

Express GROUP_CONCAT(Object express, [String sep = "','"]) {
  return ExpressFunc("GROUP_CONCAT", [express, sep]);
}

Express STRING_AGG(Object express, [String sep = "','"]) {
  return ExpressFunc("STRING_AGG", [express, sep]);
}

Express PERCENTILE(Object express, double p) {
  return ExpressFunc("PERCENTILE", [express, p]);
}

Express PERCENTILE_CONT(Object express, double p) {
  return ExpressFunc("PERCENTILE_CONT", [express, p]);
}

Express PERCENTILE_DISC(Object express, double p) {
  return ExpressFunc("PERCENTILE_DISC", [express, p]);
}

class ExpressFunc extends Express {
  ExpressFunc(super.name, [List<Object> args = const []]) {
    this.buffer.buffer.write("(");
    if (args.isNotEmpty) {
      this << args;
    }
    this.buffer.buffer.write(")");
  }
}
