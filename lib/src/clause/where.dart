part of '../sql.dart';

class WhereResult {
  final String clause;
  final AnyList args;

  WhereResult(this.clause, this.args);

  @override
  String toString() {
    return "$clause, Args: $args";
  }
}

class Where {
  final OpSQL op;
  final dynamic left;
  final dynamic right;

  Where(this.left, this.op, this.right);

  Where.raw(String clause, [AnyList? args]) : op = OpSQL.raw, left = clause, right = args;

  Where AND(Where w) {
    return Where(this, OpSQL.and, w);
  }

  Where OR(Where w) {
    return Where(this, OpSQL.or, w);
  }

  WhereResult result() {
    AnyList ls = [];
    return WhereResult(build(ls), ls);
  }

  String build(AnyList args) {
    if (op == OpSQL.raw) {
      AnyList? ls = right;
      if (ls != null) {
        args.addAll(ls);
      }
      return left as String;
    }
    if (op == OpSQL.and || op == OpSQL.or) {
      assert(left is Where);
      assert(right is Where);
      Where lw = left as Where;
      Where rw = right as Where;
      String lstr = lw.build(args);
      String rstr = rw.build(args);
      if (lstr.isEmpty) return rstr;
      if (rstr.isEmpty) return lstr;
      if (op == OpSQL.and) {
        return "${lstr.bracedIf(lw.op == OpSQL.or)} ${op.op} ${rstr.bracedIf(rw.op == OpSQL.or)}";
      } else {
        return "$lstr ${op.op} $rstr";
      }
    }
    if (_binaryOps.contains(op)) {
      assert(left != null);

      if (left is String) {
        if (right is FieldProto) {
          String rightName = (right as FieldProto).nameSQL;
          return "$left ${op.op} $rightName ";
        }
        if (right is num) {
          return "$left ${op.op} $right ";
        }
        args.add(right);
        return "$left ${op.op} ? ";
      }
      if (left is FieldProto) {
        String leftName = (left as FieldProto).nameSQL;
        if (right is FieldProto) {
          String rightName = (right as FieldProto).nameSQL;
          return "$leftName ${op.op} $rightName ";
        }
        if (right is num) {
          return "$leftName ${op.op} $right ";
        }
        args.add(right);
        return "$leftName ${op.op} ? ";
      }
    }
    if (op == OpSQL.like) {
      assert(right is String);
      String rs = right as String;
      if (left is String) {
        return "$left ${op.op} ${rs.braced}";
      } else if (left is FieldProto) {
        return "${(left as FieldProto).nameSQL} ${op.op} ${rs.braced} ";
      }
    }

    errorSQL("Where错误, op:$op, left: $left, right:$right");
  }
}

extension ListWhereExt on List<Where> {
  Where and() {
    return AND_ALL(this);
  }

  Where or() {
    return OR_ALL(this);
  }
}

Where OR_ALL(List<Where> ws) {
  if (ws.isEmpty) return Where.raw("");
  if (ws.length == 1) return ws.first;
  if (ws.length == 2) return OR_W(ws.first, ws.second!);
  return OR_W(ws.first, OR_ALL(ws.sublist(1)));
}

Where AND_ALL(List<Where> ws) {
  if (ws.isEmpty) return Where.raw("");
  if (ws.length == 1) return ws.first;
  if (ws.length == 2) return AND_W(ws.first, ws.second!);
  return AND_W(ws.first, AND_ALL(ws.sublist(1)));
}

Where AND_W(Where left, Where right) {
  return Where(left, OpSQL.and, right);
}

Where OR_W(Where left, Where right) {
  return Where(left, OpSQL.or, right);
}

extension StringWhereExt on String {
  Where IN(AnyList values) {
    var a = values.map((e) => "?").join(",");
    return Where.raw("$this IN ($a) ", values);
  }

  Where EQ(dynamic value) {
    return Where(this, OpSQL.eq, value);
  }

  Where NE(dynamic value) {
    return Where(this, OpSQL.ne, value);
  }

  Where GE(dynamic value) {
    return Where(this, OpSQL.ge, value);
  }

  Where LE(dynamic value) {
    return Where(this, OpSQL.le, value);
  }

  Where GT(dynamic value) {
    return Where(this, OpSQL.gt, value);
  }

  Where LT(dynamic value) {
    return Where(this, OpSQL.lt, value);
  }

  Where LIKE(dynamic value) {
    return Where(this, OpSQL.like, value);
  }
}

extension FieldWhereExt on FieldProto {
  Where IN(AnyList values) {
    var a = values.map((e) => "?").join(",");
    return Where.raw("${this.nameSQL} IN ($a) ", values);
  }

  Where EQ(dynamic value) {
    return Where(this, OpSQL.eq, value);
  }

  Where NE(dynamic value) {
    return Where(this, OpSQL.ne, value);
  }

  Where GE(dynamic value) {
    return Where(this, OpSQL.ge, value);
  }

  Where LE(dynamic value) {
    return Where(this, OpSQL.le, value);
  }

  Where GT(dynamic value) {
    return Where(this, OpSQL.gt, value);
  }

  Where LT(dynamic value) {
    return Where(this, OpSQL.lt, value);
  }

  Where LIKE(dynamic value) {
    return Where(this, OpSQL.like, value);
  }

  String get ASC => "${this.nameSQL} ASC";

  String get DESC => "${this.nameSQL} DESC";
}

enum OpSQL {
  raw("RAW"),
  and("AND"),
  or("OR"),
  eq("="),
  ne("!="),
  ge(">"),
  le("<"),
  gt(">="),
  lt("<="),
  like("LIKE");

  const OpSQL(this.op);

  final String op;
}

List<OpSQL> _binaryOps = [OpSQL.eq, OpSQL.ne, OpSQL.ge, OpSQL.le, OpSQL.gt, OpSQL.lt];
