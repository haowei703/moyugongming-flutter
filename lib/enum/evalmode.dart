class EvalMode {
  static const EvalMode word = EvalMode._internal(0);
  static const EvalMode sentence = EvalMode._internal(1);

  final int value;

  const EvalMode._internal(this.value);
}