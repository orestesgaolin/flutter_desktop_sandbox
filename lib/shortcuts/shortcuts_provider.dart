import 'package:flutter/widgets.dart';
import 'package:sandbox/shortcuts/intents.dart';
import 'package:sandbox/shortcuts/shortcut_model.dart';

/// A provider class that manages custom shortcuts
class ShortcutsProvider extends ChangeNotifier {
  /// The list of custom shortcuts
  final List<CustomShortcut> _shortcuts = [];

  /// Getter for shortcuts
  List<CustomShortcut> get shortcuts => List.unmodifiable(_shortcuts);

  /// Constructor with optional initial shortcuts
  ShortcutsProvider({List<CustomShortcut>? initialShortcuts}) {
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

  /// Convert shortcuts to a map of key sets to intents for use with Flutter's Shortcuts widget
  Map<LogicalKeySet, Intent> getShortcutsMap() {
    return {
      for (final shortcut in _shortcuts) shortcut.keys: findById(shortcut.intentId),
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
}
