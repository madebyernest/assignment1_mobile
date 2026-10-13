import 'package:flutter/material.dart';
import '../calc_engine.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});
  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  bool _dark = true; // Feature: theme toggle

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator State Lab',
      debugShowCheckedModeBanner: false,
      themeAnimationDuration: const Duration(milliseconds: 350),
      themeAnimationCurve: Curves.easeInOut,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.indigo,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
      ),
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      home: CalculatorPage(
        isDark: _dark,
        onToggleTheme: () => setState(() => _dark = !_dark),
      ),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  const CalculatorPage(
      {super.key, required this.isDark, required this.onToggleTheme});
  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final CalcEngine _calc = CalcEngine();

  void _act(void Function() action) => setState(action);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        actions: [
          Semantics(
            label: 'Theme toggle',
            child: IconButton(
              key: const Key('theme_toggle'),
              tooltip: widget.isDark ? 'Switch to light theme' : 'Switch to dark theme',
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  widget.isDark ? Icons.light_mode : Icons.dark_mode,
                  key: ValueKey(widget.isDark),
                ),
              ),
              onPressed: widget.onToggleTheme,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(flex: 2, child: _buildDisplay(cs)),
              const SizedBox(height: 12),
              Expanded(flex: 5, child: _buildKeypad(cs)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisplay(ColorScheme cs) {
    final isError = _calc.hasError;
    return Semantics(
      liveRegion: true, // announces results and errors to TalkBack
      label: isError
          ? 'Error: ${_calc.display}. Press a digit or AC to recover.'
          : 'Display ${_calc.display}'
              '${_calc.expression.isNotEmpty ? ', pending ${_calc.expression}' : ''}',
      child: ExcludeSemantics(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: isError ? Border.all(color: cs.error, width: 2) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _calc.expression,
                key: const Key('expression'),
                style: TextStyle(fontSize: 20, color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _calc.display,
                    key: const Key('display'),
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: isError ? 36 : 64,
                      fontWeight: FontWeight.w300,
                      color: isError ? cs.error : cs.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad(ColorScheme cs) {
    Widget row(List<Widget> kids) => Expanded(
          child: Row(children: kids),
        );
    return Column(children: [
      row([_num('7'), _num('8'), _num('9'), _op('÷', 'divide')]),
      row([_num('4'), _num('5'), _num('6'), _op('×', 'multiply')]),
      row([_num('1'), _num('2'), _num('3'), _op('−', 'subtract')]),
      row([_ac(cs), _num('0'), _equals(cs), _op('+', 'add')]),
    ]);
  }

  Widget _num(String d) => _CalcButton(
        label: d,
        semanticLabel: d,
        onTap: () => _act(() => _calc.digit(d)),
      );

  Widget _op(String symbol, String name) {
    final selected = _calc.pendingOp == symbol && _calc.awaitingOperand;
    return _CalcButton(
      label: symbol,
      semanticLabel: name,
      kind: selected ? _Kind.operatorSelected : _Kind.operator,
      onTap: () => _act(() => _calc.operator(symbol)),
    );
  }

  Widget _ac(ColorScheme cs) => _CalcButton(
        label: 'AC',
        semanticLabel: 'All clear',
        kind: _Kind.clear,
        onTap: () => _act(_calc.clearAll),
      );

  Widget _equals(ColorScheme cs) => _CalcButton(
        label: '=',
        semanticLabel: 'equals',
        kind: _Kind.equals,
        onTap: () => _act(_calc.equals),
      );
}

enum _Kind { number, operator, operatorSelected, clear, equals }

class _CalcButton extends StatelessWidget {
  final String label;
  final String semanticLabel;
  final VoidCallback onTap;
  final _Kind kind;
  const _CalcButton({
    required this.label,
    required this.semanticLabel,
    required this.onTap,
    this.kind = _Kind.number,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Color bg, fg;
    switch (kind) {
      case _Kind.operator:
        bg = cs.secondaryContainer;
        fg = cs.onSecondaryContainer;
        break;
      case _Kind.operatorSelected:
        bg = cs.secondary;
        fg = cs.onSecondary;
        break;
      case _Kind.clear:
        bg = cs.errorContainer;
        fg = cs.onErrorContainer;
        break;
      case _Kind.equals:
        bg = cs.primary;
        fg = cs.onPrimary;
        break;
      case _Kind.number:
        bg = cs.surfaceContainerHigh;
        fg = cs.onSurface;
    }
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Semantics(
          button: true,
          label: semanticLabel,
          excludeSemantics: true,
          onTap: onTap,
          child: Material(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: Key('btn_$label'),
              onTap: onTap,
              child: Center(
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(label,
                        style: TextStyle(fontSize: 30, color: fg)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}