part of '../sql.dart';

class Where extends Express {
  Where(super.express, {super.args});

  Where AND(Where w) {
    return WhereAnd(this, w);
  }

  Where OR(Where w) {
    return WhereOr(this, w);
  }
}

Set<String> _likeDenyChars = {' ', '"', '\'', ';', ',', '\$', '/', '?', ':', '<', '>', '#', '(', ')', '{', '}'};

// only '_' and '%' allowed
class WhereLike extends Where {
  WhereLike(Object left, String pattern) : super("") {
    if (left is Express) this.args.addAll(left.args);
    for (var a in _likeDenyChars) {
      if (pattern.contains(a)) errorSQL("Deny Char: $a , in: $pattern");
    }
    this << _clause(left) << "LIKE" << "'" << pattern << "'";
  }
}

class WhereIn extends Where {
  WhereIn(Object left, Iterable<dynamic> items) : super("") {
    if (left is Express) this.args.addAll(left.args);
    var a = items
        .map((e) {
          if (e is String) {
            this.args.add(e);
            return "?";
          } else if (e is num) {
            return e.toString();
          } else {
            return _clause(e);
          }
        })
        .join(",");
    this << _clause(left) << "IN" << "(" << a << ")";
  }
}

class WhereOp extends Where {
  WhereOp(Object left, String op, Object right) : super("") {
    if (left is Express) this.args.addAll(left.args);
    if (right is Express) this.args.addAll(right.args);
    if (right is String) {
      this << _clause(left) << op << "?";
      this.args.add(right);
    } else {
      this << _clause(left) << op << _clause(right);
    }
  }
}

class WhereAnd extends Where {
  WhereAnd(Where left, Where right) : super("") {
    this.args.addAll(left.args);
    this.args.addAll(right.args);
    if (left is WhereOr) {
      this << "(" << left.sql << ")" << "AND";
    } else {
      this << left.sql << "AND";
    }
    if (right is WhereOr) {
      this << "(" << right.sql << ")";
    } else {
      this << right.sql;
    }
  }
}

class WhereOr extends Where {
  WhereOr(Where left, Where right) : super("") {
    this.args.addAll(left.args);
    this.args.addAll(right.args);
    this << left.sql << "OR" << right.sql;
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
  if (ws.isEmpty) return Where("");
  if (ws.length == 1) return ws.first;
  if (ws.length == 2) return OR_W(ws.first, ws.second!);
  return OR_W(ws.first, OR_ALL(ws.sublist(1)));
}

Where AND_ALL(List<Where> ws) {
  if (ws.isEmpty) return Where("");
  if (ws.length == 1) return ws.first;
  if (ws.length == 2) return AND_W(ws.first, ws.second!);
  return AND_W(ws.first, AND_ALL(ws.sublist(1)));
}

Where AND_W(Where left, Where right) {
  return WhereAnd(left, right);
}

Where OR_W(Where left, Where right) {
  return WhereOr(left, right);
}

extension StringWhereExt on String {
  WhereLike LIKE(dynamic value) {
    return WhereLike(this, value);
  }

  Where IN(AnyList values) {
    return WhereIn(this, values);
  }

  Where EQ(dynamic value) {
    return WhereOp(this, "=", value);
  }

  Where NE(dynamic value) {
    return WhereOp(this, "!=", value);
  }

  Where GE(dynamic value) {
    return WhereOp(this, ">=", value);
  }

  Where LE(dynamic value) {
    return WhereOp(this, "<=", value);
  }

  Where GT(dynamic value) {
    return WhereOp(this, ">", value);
  }

  Where LT(dynamic value) {
    return WhereOp(this, "<", value);
  }
}

// where
extension WhereEnum<T extends TableColumn<T>> on TableColumn<T> {
  WhereLike LIKE(dynamic value) {
    return WhereLike(this, value);
  }

  Where IN(AnyList values) {
    return WhereIn(this, values);
  }

  Where EQ(dynamic value) {
    return WhereOp(this, "=", value);
  }

  Where NE(dynamic value) {
    return WhereOp(this, "!=", value);
  }

  Where GE(dynamic value) {
    return WhereOp(this, ">=", value);
  }

  Where LE(dynamic value) {
    return WhereOp(this, "<=", value);
  }

  Where GT(dynamic value) {
    return WhereOp(this, ">", value);
  }

  Where LT(dynamic value) {
    return WhereOp(this, "<", value);
  }
}

extension on FieldProto {
  WhereLike LIKE(dynamic value) {
    return WhereLike(this, value);
  }

  Where IN(AnyList values) {
    return WhereIn(this, values);
  }

  Where EQ(dynamic value) {
    return WhereOp(this, "=", value);
  }

  Where NE(dynamic value) {
    return WhereOp(this, "!=", value);
  }

  Where GE(dynamic value) {
    return WhereOp(this, ">=", value);
  }

  Where LE(dynamic value) {
    return WhereOp(this, "<=", value);
  }

  Where GT(dynamic value) {
    return WhereOp(this, ">", value);
  }

  Where LT(dynamic value) {
    return WhereOp(this, "<", value);
  }
}
