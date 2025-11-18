part of '../sql.dart';

class Where extends Express {
  Where(super.express, {super.args});

  @override
  Where get braced => Where("($sql)", args: this.args);

  Where AND(Where w) {
    return _WhereAnd(this, w);
  }

  Where OR(Where w) {
    return _WhereOr(this, w);
  }

  Where operator &(Where w) {
    return _WhereAnd(this, w);
  }

  Where operator |(Where w) {
    return _WhereOr(this, w);
  }
}

Set<String> _likeDenyChars = {' ', '"', '\'', ';', ',', '\$', '/', '?', ':', '<', '>', '#', '(', ')', '{', '}'};

// only '_' and '%' allowed
class _WhereLike extends Where {
  _WhereLike(Object left, String pattern) : super("") {
    for (var a in _likeDenyChars) {
      if (pattern.contains(a)) errorSQL("Deny Char: $a , in: $pattern");
    }
    this << left << "LIKE" << "'" << pattern << "'";
  }
}

class _WhereIn extends Where {
  _WhereIn(Object left, Iterable<dynamic> items) : super("") {
    if (items.isEmpty) {
      errorSQL("IN items is empty");
    }
    this << left << "IN" << "(";
    bool first = true;
    for (var item in items) {
      if (!first) this << ",";
      first = false;
      if (item is String) {
        this.args.add(item);
        this << "?";
      } else {
        this << item;
      }
    }
    this << ")";
  }
}

class _WhereOp extends Where {
  _WhereOp(Object left, String op, Object right) : super("") {
    this << left << op;
    if (right is String) {
      this << "?";
      this.args.add(right);
    } else {
      this << right;
    }
  }
}

class _WhereAnd extends Where {
  _WhereAnd(Where left, Where right) : super("") {
    if (left is _WhereOr) {
      this << "(" << left << ")" << "AND";
    } else {
      this << left << "AND";
    }
    if (right is _WhereOr) {
      this << "(" << right << ")";
    } else {
      this << right;
    }
  }
}

class _WhereOr extends Where {
  _WhereOr(Where left, Where right) : super("") {
    this << left << "OR" << right;
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
  if (ws.length == 2) return ws.first.OR(ws.second!);
  return ws.first.OR(OR_ALL(ws.sublist(1)));
}

Where AND_ALL(List<Where> ws) {
  if (ws.isEmpty) return Where("");
  if (ws.length == 1) return ws.first;
  if (ws.length == 2) return ws.first.AND(ws.second!);
  return ws.first.AND(AND_ALL(ws.sublist(1)));
}

extension StringWhereExt on String {
  Where LIKE(dynamic value) {
    return _WhereLike(this, value);
  }

  Where IN(AnyList values) {
    return _WhereIn(this, values);
  }

  Where EQ(dynamic value) {
    return _WhereOp(this, "=", value);
  }

  Where NE(dynamic value) {
    return _WhereOp(this, "!=", value);
  }

  Where GE(dynamic value) {
    return _WhereOp(this, ">=", value);
  }

  Where LE(dynamic value) {
    return _WhereOp(this, "<=", value);
  }

  Where GT(dynamic value) {
    return _WhereOp(this, ">", value);
  }

  Where LT(dynamic value) {
    return _WhereOp(this, "<", value);
  }
}

// where
extension WhereEnum<T extends TableColumn<T>> on TableColumn<T> {
  Where LIKE(dynamic value) {
    return _WhereLike(this, value);
  }

  Where IN(AnyList values) {
    return _WhereIn(this, values);
  }

  Where EQ(dynamic value) {
    return _WhereOp(this, "=", value);
  }

  Where NE(dynamic value) {
    return _WhereOp(this, "!=", value);
  }

  Where GE(dynamic value) {
    return _WhereOp(this, ">=", value);
  }

  Where LE(dynamic value) {
    return _WhereOp(this, "<=", value);
  }

  Where GT(dynamic value) {
    return _WhereOp(this, ">", value);
  }

  Where LT(dynamic value) {
    return _WhereOp(this, "<", value);
  }
}

extension on FieldProto {
  Where LIKE(dynamic value) {
    return _WhereLike(this, value);
  }

  Where IN(AnyList values) {
    return _WhereIn(this, values);
  }

  Where EQ(dynamic value) {
    return _WhereOp(this, "=", value);
  }

  Where NE(dynamic value) {
    return _WhereOp(this, "!=", value);
  }

  Where GE(dynamic value) {
    return _WhereOp(this, ">=", value);
  }

  Where LE(dynamic value) {
    return _WhereOp(this, "<=", value);
  }

  Where GT(dynamic value) {
    return _WhereOp(this, ">", value);
  }

  Where LT(dynamic value) {
    return _WhereOp(this, "<", value);
  }
}
