part of '../sql.dart';

Express ROW_NUMBER() {
  return ExpressFunc("ROW_NUMBER");
}

Express RANK() {
  return ExpressFunc("RANK");
}

Express DENSE_RANK() {
  return ExpressFunc("DENSE_RANK");
}

Express PERCENT_RANK() {
  return ExpressFunc("PERCENT_RANK");
}

Express CUME_DIST() {
  return ExpressFunc("CUME_DIST");
}

Express NTILE(int n) {
  return ExpressFunc("NTILE", [n]);
}

Express FIRST_VALUE(Object express) {
  return ExpressFunc("FIRST_VALUE", [express]);
}

Express LAST_VALUE(Object express) {
  return ExpressFunc("LAST_VALUE", [express]);
}

Express NTH_VALUE(Object express, int n) {
  return ExpressFunc("NTH_VALUE", [express, n]);
}

Express LAG(Object express, [int? offset, Object? defaultValue]) {
  return ExpressFunc("LAG", [express, ?offset, ?defaultValue]);
}

Express LEAD(Object express, [int? offset, Object? defaultValue]) {
  return ExpressFunc("LEAD", [express, ?offset, ?defaultValue]);
}
