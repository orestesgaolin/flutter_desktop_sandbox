import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sandbox/theme.dart';

/// A widget that captures keyboard input to record shortcuts
class KeyRecorder extends StatefulWidget {
  /// Callback when a shortcut is recorded
  final void Function(LogicalKeySet) onKeysRecorded;

  /// Initial keys if editing an existing shortcut
  final LogicalKeySet? initialKeys;

  const KeyRecorder({
    super.key,
    required this.onKeysRecorded,
    this.initialKeys,
  });

  @override
  State<KeyRecorder> createState() => _KeyRecorderState();
}

class _KeyRecorderState extends State<KeyRecorder> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'KeyRecorder');
  Set<LogicalKeyboardKey> _pressedKeys = {};
  bool _isRecording = false;
  bool _justStartedAndWaitingForKeyUp = false;
  LogicalKeySet? _currentKeys;
  bool _isFocused = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _currentKeys = widget.initialKeys;
    if (widget.initialKeys != null) {
      _pressedKeys = Set.from(widget.initialKeys!.keys);
    }
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void didUpdateWidget(KeyRecorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialKeys != oldWidget.initialKeys) {
      _currentKeys = widget.initialKeys;
      if (widget.initialKeys != null) {
        _pressedKeys = Set.from(widget.initialKeys!.keys);
      } else {
        _pressedKeys = {};
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _pressedKeys = {};
    });
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  void _finishRecording() {
    if (_pressedKeys.isNotEmpty) {
      final keySet = LogicalKeySet.fromSet(_pressedKeys);
      _currentKeys = keySet;
      widget.onKeysRecorded(keySet);
    }
    setState(() {
      _isRecording = false;
    });
  }

  String _getDisplayText() {
    if (_isRecording) {
      if (_pressedKeys.isEmpty) {
        return 'Press keys...';
      }
      return _getKeysDescription(_pressedKeys);
    }

    if (_currentKeys == null) {
      return 'Click to record shortcut';
    }

    return _getKeysDescription(_currentKeys!.keys);
  }

  String _getKeysDescription(Iterable<LogicalKeyboardKey> keys) {
    final keyLabels = <String>[];

    // Check for modifier keys
    if (keys.any((key) => key == LogicalKeyboardKey.meta)) {
      keyLabels.add('⌘');
    }
    if (keys.any((key) => key == LogicalKeyboardKey.shift)) {
      keyLabels.add('⇧');
    }
    if (keys.any((key) => key == LogicalKeyboardKey.alt)) {
      keyLabels.add('⌥');
    }
    if (keys.any((key) => key == LogicalKeyboardKey.control)) {
      keyLabels.add('⌃');
    }

    // Add non-modifier keys
    for (final key in keys) {
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
  String? _getKeyLabel(LogicalKeyboardKey key) {
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

  @override
  Widget build(BuildContext context) {
    return Actions(
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (ActivateIntent intent) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _justStartedAndWaitingForKeyUp = true;
              _startRecording();
            });
            setState(() {});
            return null;
          },
        ),
      },

      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (KeyEvent event) {
          if (!_isRecording) return;
          if (_justStartedAndWaitingForKeyUp) {
            if (event is KeyUpEvent) {
              _justStartedAndWaitingForKeyUp = false;
            }
            return;
          }

          if (event is KeyDownEvent) {
            setState(() {
              _pressedKeys.add(event.logicalKey);
            });
          } else if (event is KeyUpEvent) {
            // When a key is released, finish recording if it's not a modifier key
            if (!_isModifierKey(event.logicalKey)) {
              _finishRecording();
            }
          }
        },
        child: GestureDetector(
          onTap: _startRecording,
          child: MouseRegion(
            onEnter: (_) {
              setState(() {
                _isHovered = true;
              });
            },
            onExit: (_) {
              setState(() {
                _isHovered = false;
              });
            },
            cursor: SystemMouseCursors.click,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: AppTheme.of(context).dynamicCardDecoration(
                focused: _isFocused,
                hovered: _isHovered,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _getDisplayText(),
                      style: TextStyle(
                        color: _isRecording ? Colors.blue : Colors.black,
                        fontWeight: _isRecording ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                  if (_isRecording && _pressedKeys.isEmpty)
                    Text(
                      'Press keys...',
                      style: TextStyle(
                        color: Colors.blue,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _isModifierKey(LogicalKeyboardKey key) {
    return [
      LogicalKeyboardKey.meta,
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.alt,
      LogicalKeyboardKey.control,
    ].contains(key);
  }
}
