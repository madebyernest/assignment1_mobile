# Calculator Assignment

A Flutter calculator that evaluates expressions **left to right**. For example, `2 + 3 × 4 = 20`.

- **Course:** CSC 4360
- **Author:** Ernest Fistik (Student ID: 002832382)
- **Selected features:** Theme toggle, Clear/AC, error handling

## Features

- Basic arithmetic with digits 0–9
- Running total and pending operator display
- Light/dark themes with an animated toggle
- AC resets all calculator state
- Division-by-zero and overflow handling
- Responsive layout, large touch targets, and screen-reader labels

## Requirements

Flutter SDK and Chrome, Edge, or an Android device/emulator.

## Run

```bash
flutter pub get
flutter run
```

## Test

```bash
flutter test
```

Tests in `test/calc_engine_test.dart` cover state transitions, errors, and boundary cases.

## Build Android APK

```bash
flutter build apk
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Project Structure

```text
lib/
  main.dart          UI and theme toggle
  calc_engine.dart   Calculator state machine
test/
  calc_engine_test.dart
```

## How It Works

`CalcEngine` manages calculator state through `digit()`, `operator()`, `equals()`, and `clearAll()`. The UI updates through `setState()`.

**Key behaviors:**
- Operators apply the pending operation immediately.
- Repeated operators replace the pending operator.
- Equals is ignored when awaiting an operand.
- Input is limited to 12 digits.
- Results ≥ 1e15 or non-finite results show an error.
- Results use up to 10 significant digits.
- Errors recover through digit input or AC.

## AI Assistance

Claude (Anthropic) was used as assistance (especially for this README). I reviewed, tested, and did most of the work myself.