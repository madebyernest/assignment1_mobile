/// Pure Dart left-to-right running-total calculator
class CalcEngine {
  static const int maxDigits = 12;
  static const String divideByZeroMessage = 'Cannot divide by 0';
  static const String overflowMessage = 'Result too large';

  double accumulator = 0; // running total
  String input = '0'; // current operand being typed
  String? pendingOp; // one of + - × ÷
  bool awaitingOperand = false; // operator chosen, next digit starts operand
  bool justEvaluated = false; // equals was just pressed
  String? error; // non-null while in the error state

  bool get hasError => error != null;

  /// What the main display shows.
  String get display {
    if (hasError) return error!;
    if (awaitingOperand || justEvaluated) return format(accumulator);
    return input;
  }

  /// Secondary line, e.g. "5 ×" (running total + pending operator).
  String get expression =>
      (pendingOp != null && !hasError) ? '${format(accumulator)} $pendingOp' : '';

  /// AC: clears display, accumulator, pending operator, and result phase.
  void clearAll() {
    accumulator = 0;
    input = '0';
    pendingOp = null;
    awaitingOperand = false;
    justEvaluated = false;
    error = null;
  }

  void digit(String d) {
    // A digit starts a fresh calculation.
    // A digit after equals also starts a fresh calculation.
    if (hasError || justEvaluated) clearAll();
    if (awaitingOperand) {
      input = d;
      awaitingOperand = false;
    } else if (input.length < maxDigits) {
      input = input == '0' ? d : input + d;
    }
  }

  void operator(String op) {
    if (hasError) return;
    if (justEvaluated) {
      // Continues from the previous result
      pendingOp = op;
      justEvaluated = false;
      awaitingOperand = true;
      return;
    }
    if (awaitingOperand) {
      // Rreplace the pending operator
      pendingOp = op;
      return;
    }
    final value = double.parse(input);
    if (pendingOp != null) {
      if (!_applyPending(value)) return; // error state set
    } else {
      accumulator = value;
    }
    pendingOp = op;
    awaitingOperand = true;
    input = '0';
  }

  void equals() {
    if (hasError) return;
    // Equals with no new operand is ignored
    if (pendingOp == null || awaitingOperand) return;
    if (!_applyPending(double.parse(input))) return;
    pendingOp = null;
    justEvaluated = true;
    input = '0';
  }

  bool _applyPending(double b) {
    final a = accumulator;
    double r;
    switch (pendingOp) {
      case '+':
        r = a + b;
        break;
      case '-':
      case '−':
        r = a - b;
        break;
      case '×':
        r = a * b;
        break;
      case '÷':
        if (b == 0) {
          error = divideByZeroMessage;
          return false;
        }
        r = a / b;
        break;
      default:
        r = b;
    }
    if (!r.isFinite || r.abs() >= 1e15) {
      error = overflowMessage;
      return false;
    }
    accumulator = r;
    return true;
  }

  static String format(double v) {
    if (v == v.truncateToDouble() && v.abs() < 1e15) {
      return v.toInt().toString();
    }
    var s = v.toStringAsPrecision(10);
    if (s.contains('e')) return s;
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    }
    return s;
  }
}