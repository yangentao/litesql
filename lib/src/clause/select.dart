part of '../sql.dart';

/// SELECT("name", Person.name, "name".AS("a"))
/// String, Express, TableColumn
Express SELECT(AnyList columns) {
  var e = Express("SELECT");
  if (columns.isEmpty) {
    e << "*";
  } else {
    e << columns;
  }
  return e;
}

Express SELECT_ALL() {
  return Express("SELECT *");
}

Express SELECT_DISTINCT(AnyList columns) {
  var e = Express("SELECT DISTINCT");
  if (columns.isEmpty) {
    e << "*";
  } else {
    e << columns;
  }
  return e;
}

extension ExpressExt on Express {
  // String OR Express OR Type
  Express FROM(Object express) {
    this << "FROM";
    switch (express) {
      case String s:
        return this << s;
      case Express ex:
        return this << ex;
      case Type t:
        return this << t.proto.nameSQL;
    }
    errorSQL("FROM not support parameter: $express");
  }

  // String OR Express
  Express WHERE(Object express) {
    switch (express) {
      case String s:
        return this << "WHERE" << s;
      case Express ex:
        return this << "WHERE" << ex;
    }
    errorSQL("WHERE not support parameter: $express");
  }

  Express GROUP_BY(Object express) {
    return this << "GROUP_BY" << express;
  }

  Express HAVING(Object express) {
    return this << "HAVING" << express;
  }

  Express WINDOW(String name, Object express) {
    return this << "WINDOW" << name << "AS" << "(" << express << ")";
  }

  /// ORDER_BY("name".ASC)
  /// ORDER_BY(["name".ASC, Configs.name.DESC])
  Express ORDER_BY(Object express) {
    this << "ORDER BY" << express;
    return this;
  }

  Express LIMIT(int limit, [int? offset]) {
    if (offset == null) return this << "LIMIT" << limit.toString();
    return this << "LIMIT" << limit.toString() << "," << offset.toString();
  }

  Express OFFSET(int offset) {
    return this << "OFFSET" << offset.toString();
  }
}

Express PARTITION_BY(Object express) {
  var e = Express("PARTITION BY");
  e << express;
  return e;
}

Express ORDER_BY(Object express) {
  var e = Express("ORDER BY");
  e << express;
  return e;
}

/// return String OR Express
Object _clause(dynamic value) {
  switch (value) {
    case String s:
      return s;
    case Express e:
      return e;
    case TableColumn c:
      return c.fullname;
    case Type t:
      return t.proto.nameSQL;
    case FieldProto f:
      return f.fullname;
    case AnyList ls:
      AnyList args = [];
      String s = ls.joinMap(", ", (e) {
        var r = _clause(e);
        switch (r) {
          case String a:
            return a;
          case Express x1:
            args.addAll(x1.args);
            return x1.sql;
          default:
            errorSQL("BAD result");
        }
      });
      return args.isEmpty ? s : Express(s, args: args);
  }
  errorSQL("Unknown value: $value ");
}
