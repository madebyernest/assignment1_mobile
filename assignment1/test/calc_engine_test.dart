import 'package:flutter_test/flutter_test.dart';
import 'package:assignment1/calc_engine.dart';

CalcEngine run(String keys) {
  final c = CalcEngine();
  for (final k in keys.split('')) {
    if (k == ' ') continue;
    if (RegExp(r'\d').hasMatch(k)) {
      c.digit(k);
    } else if (k == '=') {
      c.equals();
    } else if (k == 'C') {
      c.clearAll();
    } else {
      c.operator(k);
    }
  }
  return c;
}

void main() {
  test('2 + 3 shows 3 (second operand)', () => expect(run('2+3').display, '3'));
  test('2 + 3 × shows running total 5', () => expect(run('2+3×').display, '5'));
  test('2 + 3 × 4 = is 20 (left to right)', () => expect(run('2+3×4=').display, '20'));
  test('overflow -> error', () =>
    expect(run('999999999999×999999999999=').hasError, isTrue));
  test('9 + × 2 = replaces operator -> 18', () => expect(run('9+×2=').display, '18'));
  test('7 + = ignores equals, keeps pending op', () {
    final c = run('7+=');
    expect(c.display, '7');
    expect(c.pendingOp, '+');
  });
  test('digit after equals starts fresh', () {
    final c = run('2+3=');
    expect(c.display, '5');
    c.digit('8');
    expect(c.display, '8');
    expect(c.pendingOp, isNull);
  });
  test('operator after equals continues from result', () => expect(run('2+3=×4=').display, '20'));
  test('chain all four ops: 10 ÷ 4 × 2 - 1 + 6 =', () => expect(run('10÷4×2-1+6=').display, '10'));
  test('leading zeros collapse', () => expect(run('007').display, '7'));
  test('AC clears everything', () {
    final c = run('2+3×C');
    expect(c.display, '0');
    expect(c.accumulator, 0);
    expect(c.pendingOp, isNull);
    expect(c.awaitingOperand, isFalse);
    expect(c.justEvaluated, isFalse);
    // stale-accumulator check: fresh calc after AC is unaffected
    c.digit('4'); c.operator('+'); c.digit('1'); c.equals();
    expect(c.display, '5');
  });
  test('division by zero -> error', () {
    final c = run('5÷0=');
    expect(c.hasError, isTrue);
    expect(c.display, CalcEngine.divideByZeroMessage);
  });
  test('error: operator and equals ignored; digit recovers', () {
    final c = run('5÷0=');
    c.operator('+'); c.equals();
    expect(c.hasError, isTrue);
    c.digit('3');
    expect(c.hasError, isFalse);
    expect(c.display, '3');
  });
  test('error via chaining operator (5 ÷ 0 +)', () => expect(run('5÷0+').hasError, isTrue));
  test('AC recovers from error', () {
    final c = run('5÷0=');
    c.clearAll();
    expect(c.display, '0');
  });
  test('incomplete input: lone equals / lone operator', () {
    expect(run('=').display, '0');
    expect(run('+').display, '0');
    expect(run('+5=').display, '5');
  });
  test('non-integer result formatting', () => expect(run('7÷2=').display, '3.5'));
  test('1 ÷ 3 × 3 formats without float noise', () => expect(run('1÷3×3=').display, '1'));
  test('digit length capped at 12', () => expect(run('1234567890123456').display.length, 12));
  test('negative result', () => expect(run('3-5=').display, '-2'));
}