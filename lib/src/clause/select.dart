part of '../sql.dart';

void main() {
  var a = SELECT(["a", Configs.name]);
  println(a);
}

/// SELECT("name", Person.name, "name".AS("a"))
/// String, Express, TableColumn
Express SELECT(AnyList columns) {
  var e = Express("SELECT");
  if (columns.isEmpty) {
    e << "*";
  } else {
    e << _clause(columns);
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
    e << _clause(columns);
  }
  return e;
}

extension ExpressExt on Express {
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

  Express WHERE(Object express) {
    switch (express) {
      case String s:
        return this << s;
      case Express ex:
        return this << ex;
    }
    errorSQL("WHERE not support parameter: $express");
  }

  Express GROUP_BY(Object express) {
    return this << _clause(express);
  }

  Express HAVING(Object express) {
    return this << _clause(express);
  }

  Express WINDOW(String name, Object express) {
    return this << "WINDOW" << name << "AS" << "(" << _clause(express) << ")";
  }

  /// ORDER_BY("name".ASC)
  /// ORDER_BY(["name".ASC, Configs.name.DESC])
  Express ORDER_BY(Object express) {
    this << "ORDER BY" << _clause(express);
    return this;
  }

  Express LIMIT(int n) {
    return this << "LIMIT" << n.toString();
  }

  Express OFFSET(int n) {
    return this << "OFFSET" << n.toString();
  }
}

Express PARTITION_BY(Object express) {
  var e = Express("PARTITION BY");
  e << _clause(express);
  return e;
}

Object _clause(dynamic value) {
  switch (value) {
    case String s:
      return s;
    case Express e:
      return e.sql;
    case TableColumn c:
      return c.fullname;
    case Type t:
      return t.proto.nameSQL;
    case AnyList ls:
      return ls.joinMap(", ", _clause);
  }
  errorSQL("Unknown value: $value ");
}
