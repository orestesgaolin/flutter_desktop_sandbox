import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sandbox/shortcuts/intents.dart';
import 'package:sandbox/shortcuts/shortcut_model.dart';

/// A provider class that manages custom shortcuts
class ShortcutsProvider extends ChangeNotifier {
  /// The list of custom shortcuts
  final List<CustomShortcut> _shortcuts = [];

  final List<CustomShortcut> _defaultShorcuts = [
    CustomShortcut(
      id: 'open_settings',
      name: 'Open Settings',
      keys: LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.comma),
      intent: OpenSettingsIntent(),
    ),
    CustomShortcut(
      id: 'show_command_palette',
      name: 'Show Command Palette',
      keys: LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyP),
      intent: ShowCommandPaletteIntent(),
    ),
    CustomShortcut(
      id: 'open_new_tab',
      name: 'Open New Tab',
      keys: LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyT),
      intent: OpenNewTabIntent(),
    ),
    CustomShortcut(
      id: 'go_back',
      name: 'Go Back',
      keys: LogicalKeySet(LogicalKeyboardKey.backspace),
      intent: GoBackIntent(),
    ),
    for (final i in [1, 2, 3, 4, 5, 6, 7, 8, 9])
      CustomShortcut(
        id: 'select_tab_$i',
        name: 'Select Tab $i',
        keys: LogicalKeySet(
          LogicalKeyboardKey.meta,
          switch (i) {
            1 => LogicalKeyboardKey.digit1,
            2 => LogicalKeyboardKey.digit2,
            3 => LogicalKeyboardKey.digit3,
            4 => LogicalKeyboardKey.digit4,
            5 => LogicalKeyboardKey.digit5,
            6 => LogicalKeyboardKey.digit6,
            7 => LogicalKeyboardKey.digit7,
            8 => LogicalKeyboardKey.digit8,
            9 => LogicalKeyboardKey.digit9,
            _ => null,
          },
        ),
        intent: SelectTabIntent(i),
      ),
  ];

  /// Getter for shortcuts
  List<CustomShortcut> get shortcuts => List.unmodifiable(_shortcuts);

  /// Get shorcuts that need to be passed on text fields to counteract
  /// any shorctuts assigned to normal keys
  /// See more https://api.flutter.dev/flutter/widgets/DefaultTextEditingShortcuts-class.html
  /// They will emit DoNothingAndStopPropagationIntent
  Map<ShortcutActivator, Intent> getTextFieldShortcuts() {
    final allNormalKeys = LogicalKeyboardKey.knownLogicalKeys;
    final definedKeys = shortcuts.map((s) => s.keys);
    final definedSingleKeys = definedKeys.where((e) => e.triggers.length == 1).expand((e) => e.triggers);

    return {
      for (final key in definedSingleKeys) SingleActivator(key): DoNothingAndStopPropagationIntent(),
    };
  }

  /// Constructor with optional initial shortcuts
  ShortcutsProvider({List<CustomShortcut>? initialShortcuts}) {
    _shortcuts.addAll(_defaultShorcuts);
    if (initialShortcuts != null) {
      _shortcuts.addAll(initialShortcuts);
    }
  }

  /// Add a new shortcut
  void addShortcut(CustomShortcut shortcut) {
    _shortcuts.add(shortcut);
    notifyListeners();
  }

  /// Update an existing shortcut
  void updateShortcut(String id, CustomShortcut updatedShortcut) {
    final index = _shortcuts.indexWhere((s) => s.id == id);
    if (index != -1) {
      _shortcuts[index] = updatedShortcut;
      notifyListeners();
    }
  }

  /// Delete a shortcut
  void deleteShortcut(String id) {
    _shortcuts.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void resetShortcuts() {
    _shortcuts.clear();
    _shortcuts.addAll(_defaultShorcuts);
    notifyListeners();
  }

  /// Convert shortcuts to a map of key sets to intents for use with Flutter's Shortcuts widget
  Map<LogicalKeySet, Intent> getShortcutsMap() {
    return {
      for (final shortcut in _shortcuts) shortcut.keys: shortcut.intent,
    };
  }

  /// Get a shortcut by its ID
  CustomShortcut? getShortcutById(String id) {
    try {
      return _shortcuts.firstWhere((shortcut) => shortcut.id == id);
    } catch (e) {
      return null;
    }
  }

  Map<LogicalKeySet, Intent> getTabIntentShortcuts() {
    final shortcutsForIntent = shortcuts.where((s) => s.intent is SelectTabIntent).fold<Map<LogicalKeySet, Intent>>(
      {},
      (map, shortcut) {
        map[shortcut.keys] = shortcut.intent;
        return map;
      },
    );
    return shortcutsForIntent;
  }
}
