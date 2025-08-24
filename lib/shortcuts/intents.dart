import 'package:flutter/widgets.dart';

enum IntentId {
  openSettings,
  showCommandPalette,
  openNewTab,
  goBack,
  previousTab,
  nextTab,
}

sealed class CustomIntent extends Intent {
  final IntentId id;
  final String? name;
  const CustomIntent(this.id, {this.name});
}

class OpenSettingsIntent extends CustomIntent {
  const OpenSettingsIntent() : super(IntentId.openSettings, name: 'Open Settings');
}

class ShowCommandPaletteIntent extends CustomIntent {
  const ShowCommandPaletteIntent() : super(IntentId.showCommandPalette, name: 'Show Command Palette');
}

class OpenNewTabIntent extends CustomIntent {
  const OpenNewTabIntent() : super(IntentId.openNewTab, name: 'Open New Tab');
}

class GoBackIntent extends CustomIntent {
  const GoBackIntent() : super(IntentId.goBack, name: 'Go Back');
}

class NextTabIntent extends CustomIntent {
  const NextTabIntent() : super(IntentId.nextTab, name: 'Next Tab');
}

class PreviousTabIntent extends CustomIntent {
  const PreviousTabIntent() : super(IntentId.previousTab, name: 'Previous Tab');
}

CustomIntent findById(IntentId id) {
  switch (id) {
    case IntentId.openSettings:
      return const OpenSettingsIntent();
    case IntentId.showCommandPalette:
      return const ShowCommandPaletteIntent();
    case IntentId.openNewTab:
      return const OpenNewTabIntent();
    case IntentId.goBack:
      return const GoBackIntent();
    case IntentId.previousTab:
      return const PreviousTabIntent();
    case IntentId.nextTab:
      return const NextTabIntent();
  }
}
