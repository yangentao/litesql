import 'dart:typed_data';

import 'package:litesql/litesql.dart';
import 'package:println/println.dart';

void main() {
  println(access<bool>());
  println(access<int>());
  println(access<double>());
  println(access<String>());
  println(access<BlobSQL>());
  println(access<Uint8List>());
}

bool access<T>() {
  return typesSQL.contains(T);
}
