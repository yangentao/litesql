class DType<T> {
  Type get type => T;

  bool isSubtypeOf<SUPER>() {
    return this is DType<SUPER>;
  }

  bool isSuperOf<CHILD>(DType<CHILD> ch) => ch is DType<T>;

  bool acceptNull() => null is T;

  bool acceptInstance(Object? inst) => inst is T;

  static final DType<String> typeString = DType();
  static final DType<bool> typeBool = DType();
  static final DType<int> typeInt = DType();
  static final DType<double> typeDouble = DType();
  static final DType<num> typeNum = DType();

  static final DType<List<String>> typeListString = DType();
  static final DType<List<bool>> typeListBool = DType();
  static final DType<List<int>> typeListInt = DType();
  static final DType<List<double>> typeListDouble = DType();
}
