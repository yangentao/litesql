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

Express UNION(Express left, Express right) {
  Express e = Express("");
  e << left << "UNION" << right;
  return e;
}

Express UNION_ALL(Express left, Express right) {
  Express e = Express("");
  e << left << "UNION ALL" << right;
  return e;
}

Express INTERSECT(Express left, Express right) {
  Express e = Express("");
  e << left << "INTERSECT" << right;
  return e;
}

Express EXCEPT(Express left, Express right) {
  Express e = Express("");
  e << left << "EXCEPT" << right;
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
        var p = TableProto.of(t);
        return this << p.nameSQL;
      case TableProto p:
        return this << p.nameSQL;
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

  Express WINDOW_AS(String name, Object express) {
    return this << "WINDOW" << name << "AS" << "(" << express << ")";
  }

  Express WINDOWS(Object express) {
    return this << "WINDOW" << express;
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

  Express FILTER(Object express) {
    return this << "FILTER (WHERE" << express << ")";
  }

  Express OVER(Object express) {
    return this << "OVER (" << express << ")";
  }

  Express OVER_NAME(String name) {
    return this << "OVER" << name;
  }

  Express AS(Object express) {
    return this << "AS" << express;
  }

  Express get ASC => this << "ASC";

  Express get DESC => this << "DESC";
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
      return TableProto.of(t).nameSQL;
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
