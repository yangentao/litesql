part of 'sql.dart';

class LiteX {
  LiteSQL lite;

  LiteX(this.lite);
}

extension LiteSQLX on LiteSQL {
  LiteX get X => LiteX(this);
}
