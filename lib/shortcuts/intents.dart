import 'package:flutter/widgets.dart';

sealed class CustomIntent extends Intent {
  final String? name;
  const CustomIntent({this.name});

  static List<CustomIntent> get allIntents {
    return [
      const OpenSettingsIntent(),
      const ShowCommandPaletteIntent(),
      const OpenNewTabIntent(),
      const GoBackIntent(),
      const PreviousTabIntent(),
      const NextTabIntent(),
      for (var i = 1; i < 10; i++) SelectTabIntent(i),
      for (var i = 0; i < 10; i++) TypeDigitIntent(i),
    ];
  }
}

class OpenSettingsIntent extends CustomIntent {
  const OpenSettingsIntent() : super(name: 'Open Settings');
}

class ShowCommandPaletteIntent extends CustomIntent {
  const ShowCommandPaletteIntent() : super(name: 'Show Command Palette');
}

class OpenNewTabIntent extends CustomIntent {
  const OpenNewTabIntent() : super(name: 'Open New Tab');
}

class GoBackIntent extends CustomIntent {
  const GoBackIntent() : super(name: 'Go Back');
}

class NextTabIntent extends CustomIntent {
  const NextTabIntent() : super(name: 'Next Tab');
}

class PreviousTabIntent extends CustomIntent {
  const PreviousTabIntent() : super(name: 'Previous Tab');
}

class SelectTabIntent extends CustomIntent {
  final int tabIndex;
  const SelectTabIntent(this.tabIndex) : super(name: 'Select Tab $tabIndex');
}

class TypeDigitIntent extends CustomIntent {
  final int digit;
  const TypeDigitIntent(this.digit) : super(name: 'Type Digit $digit');
}