import 'package:println/println.dart';

void main() {
  enumMap[EA.a] = "EA.a";
  enumMap[EB.a] = "EB.a";
  println(enumMap[EA.a], enumMap[EB.a]);
}

Map<Enum, String> enumMap = {};

enum EA { a, b }

enum EB { a, b }
