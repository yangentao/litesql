part of '../sql.dart';

class JoinExpress extends Express {
  JoinExpress(Object left, String join, Object right) : super("") {
    this << left << join << right;
  }

  Express ON(Object express) {
    this << "ON" << express;
    return this;
  }

  Express USING(Object express) {
    this << "USING" << express;
    return this;
  }
}

extension TypeTableExt on Type {
  JoinExpress JOIN(Object other) {
    return JoinExpress(this, "JOIN", other);
  }

  JoinExpress INNER_JOIN(Object other) {
    return JoinExpress(this, "INNER JOIN", other);
  }

  JoinExpress CROSS_JOIN(Object other) {
    return JoinExpress(this, "CROSS JOIN", other);
  }

  JoinExpress LEFT_JOIN(Object other) {
    return JoinExpress(this, "LEFT JOIN", other);
  }

  JoinExpress RIGHT_JOIN(Object other) {
    return JoinExpress(this, "RIGHT JOIN", other);
  }

  JoinExpress FULL_JOIN(Object other) {
    return JoinExpress(this, "FULL JOIN", other);
  }

  JoinExpress LEFT_OUTER_JOIN(Object other) {
    return JoinExpress(this, "LEFT OUTER JOIN", other);
  }

  JoinExpress RIGHT_OUTER_JOIN(Object other) {
    return JoinExpress(this, "RIGHT OUTER JOIN", other);
  }

  JoinExpress FULL_OUTER_JOIN(Object other) {
    return JoinExpress(this, "FULL OUTER JOIN", other);
  }
}

extension StringJoinExt on String {
  JoinExpress JOIN(Object other) {
    return JoinExpress(this, "JOIN", other);
  }

  JoinExpress INNER_JOIN(Object other) {
    return JoinExpress(this, "INNER JOIN", other);
  }

  JoinExpress CROSS_JOIN(Object other) {
    return JoinExpress(this, "CROSS JOIN", other);
  }

  JoinExpress LEFT_JOIN(Object other) {
    return JoinExpress(this, "LEFT JOIN", other);
  }

  JoinExpress RIGHT_JOIN(Object other) {
    return JoinExpress(this, "RIGHT JOIN", other);
  }

  JoinExpress FULL_JOIN(Object other) {
    return JoinExpress(this, "FULL JOIN", other);
  }

  JoinExpress LEFT_OUTER_JOIN(Object other) {
    return JoinExpress(this, "LEFT OUTER JOIN", other);
  }

  JoinExpress RIGHT_OUTER_JOIN(Object other) {
    return JoinExpress(this, "RIGHT OUTER JOIN", other);
  }

  JoinExpress FULL_OUTER_JOIN(Object other) {
    return JoinExpress(this, "FULL OUTER JOIN", other);
  }
}
