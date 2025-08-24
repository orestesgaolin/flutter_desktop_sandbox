import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sandbox/shortcuts/intents.dart';

/// Represents a custom shortcut that can be defined by users
class CustomShortcut {
  /// A unique identifier for the shortcut
  final String id;

  /// Human-readable name/description of the shortcut
  final String name;

  /// The keys that need to be pressed to trigger this shortcut
  final LogicalKeySet keys;

  /// The action to perform when the shortcut is triggered
  final IntentId intentId;

  const CustomShortcut({
    required this.id,
    required this.name,
    required this.keys,
    required this.intentId,
  });

  /// Creates a copy of this shortcut with updated properties
  CustomShortcut copyWith({
    String? id,
    String? name,
    LogicalKeySet? keys,
    IntentId? intentId,
  }) {
    return CustomShortcut(
      id: id ?? this.id,
      name: name ?? this.name,
      keys: keys ?? this.keys,
      intentId: intentId ?? this.intentId,
    );
  }

  /// Returns a string representation of the key combination
  String get keysDescription {
    final keyLabels = <String>[];

    // Check for modifier keys
    if (keys.keys.any((key) => key == LogicalKeyboardKey.meta)) {
      keyLabels.add('⌘');
    }
    if (keys.keys.any((key) => key == LogicalKeyboardKey.shift)) {
      keyLabels.add('⇧');
    }
    if (keys.keys.any((key) => key == LogicalKeyboardKey.alt)) {
      keyLabels.add('⌥');
    }
    if (keys.keys.any((key) => key == LogicalKeyboardKey.control)) {
      keyLabels.add('⌃');
    }

    // Add non-modifier keys
    for (final key in keys.keys) {
      if (![
        LogicalKeyboardKey.meta,
        LogicalKeyboardKey.shift,
        LogicalKeyboardKey.alt,
        LogicalKeyboardKey.control,
      ].contains(key)) {
        final keyLabel = _getKeyLabel(key);
        if (keyLabel != null) {
          keyLabels.add(keyLabel);
        }
      }
    }

    return keyLabels.join(' + ');
  }

  /// Helper method to get a human-readable label for a key
  static String? _getKeyLabel(LogicalKeyboardKey key) {
    // Handle letter keys
    final keyLabel = key.keyLabel;
    if (keyLabel.length == 1 && RegExp(r'[A-Za-z0-9]').hasMatch(keyLabel)) {
      return keyLabel.toUpperCase();
    }

    // Common function keys
    if (key == LogicalKeyboardKey.escape) return 'Esc';
    if (key == LogicalKeyboardKey.enter) return 'Enter';
    if (key == LogicalKeyboardKey.backspace) return 'Backspace';
    if (key == LogicalKeyboardKey.tab) return 'Tab';
    if (key == LogicalKeyboardKey.space) return 'Space';

    // Try to use the key label if available
    if (keyLabel.isNotEmpty) {
      return keyLabel;
    }

    // Fallback to the debug name
    final debugName = key.debugName;
    if (debugName != null) {
      return debugName.replaceAll('LogicalKeyboardKey.', '');
    }

    return null;
  }
}
