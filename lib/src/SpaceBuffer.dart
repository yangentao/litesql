part of 'sql.dart';

void main() {
  SpaceBuffer buf = SpaceBuffer.text();
  buf << "Helo";
  println(buf);
}

extension type SpaceBuffer(StringBuffer buffer) implements StringBuffer {
  SpaceBuffer.text([String s = ""]) : this(StringBuffer(s));

  SpaceBuffer get space {
    buffer.write(" ");
    return this;
  }

  SpaceBuffer get newLine {
    buffer.writeln("");
    return this;
  }

  SpaceBuffer operator <<(String s) {
    if (s == "," || s == " ") {
      buffer.write(s);
    } else {
      if (buffer.isNotEmpty) {
        buffer.write(" ");
      }
      buffer.write(s);
    }
    return this;
  }

  SpaceBuffer add(String s, {String pre = " "}) {
    buffer.write(pre);
    buffer.write(s);
    return this;
  }

  SpaceBuffer addAll(List<String> ls, {String pre = " ", String sep = " "}) {
    buffer.write(pre);
    buffer.write(ls.join(sep));
    return this;
  }

  SpaceBuffer addLine(String s, {String pre = " "}) {
    buffer.write(pre);
    buffer.writeln(s);
    return this;
  }
}
