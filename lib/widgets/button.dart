import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sandbox/theme.dart';

/// Generic button widget that responds to focus, hover, and press events.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.semanticsLabel,
    this.focusNode,
    this.autofocus = false,
  });

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Text displayed in the button
  final String label;

  /// Optional icon to display before the label
  final IconData? icon;

  /// Optional semantics label for accessibility
  final String? semanticsLabel;

  /// Optional focus node
  final FocusNode? focusNode;

  /// Whether this widget should autofocus
  final bool autofocus;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isFocused = false;
  bool _isHovered = false;
  bool _isPressed = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;
    final theme = AppButtonTheme.of(context);

    final effectiveBackgroundColor = switch ((isEnabled, _isHovered, _isFocused, _isPressed)) {
      (true, false, false, false) => theme.backgroundColor,
      (true, true, false, false) => theme.backgroundColor.withValues(alpha: 0.8),
      (true, false, true, false) => theme.backgroundColor.withValues(alpha: 0.6),
      _ => theme.disabledBackgroundColor,
    };

    Color effectiveForegroundColor = theme.foregroundColor;
    final effectiveDisabledForegroundColor = theme.disabledForegroundColor;

    effectiveForegroundColor = isEnabled ? effectiveForegroundColor : effectiveDisabledForegroundColor;

    // Scale based on state
    final scale = _isPressed ? 0.98 : 1.0;

    return FocusableActionDetector(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      enabled: isEnabled,
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<Intent>(
          onInvoke: (Intent intent) {
            if (isEnabled) {
              widget.onPressed?.call();
            }
            return null;
          },
        ),
      },
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.enter): ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.space): ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.tab): NextFocusIntent(),
        LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab): PreviousFocusIntent(),
      },
      onShowFocusHighlight: (focused) {
        setState(() {
          _isFocused = focused;
        });
      },
      onShowHoverHighlight: (hovered) {
        setState(() {
          _isHovered = hovered;
        });
      },
      onFocusChange: (value) {
        setState(() {
          _isFocused = value;
        });
      },
      descendantsAreFocusable: false,
      descendantsAreTraversable: false,
      mouseCursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
        onTap: widget.onPressed,
        child: Semantics(
          button: true,
          enabled: isEnabled,
          label: widget.semanticsLabel ?? widget.label,
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 50),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 50),
              padding: theme.padding,
              decoration: BoxDecoration(
                color: effectiveBackgroundColor,
                borderRadius: BorderRadius.circular(theme.borderRadius),
                border: _isFocused
                    ? Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 0.5,
                      )
                    : Border.all(
                        color: Colors.transparent,
                        width: 0.5,
                      ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: effectiveForegroundColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: effectiveForegroundColor,
                      fontWeight: FontWeight.bold,
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
}
