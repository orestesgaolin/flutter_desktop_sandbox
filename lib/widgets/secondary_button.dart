import 'package:flutter/widgets.dart';
import 'package:sandbox/theme.dart';
import 'package:sandbox/widgets/button.dart';

/// A secondary button that uses the same underlying behavior as AppButton
/// but with a different visual style.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
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
  Widget build(BuildContext context) {
    return AppButton(
      onPressed: onPressed,
      label: label,
      icon: icon,
      semanticsLabel: semanticsLabel,
      focusNode: focusNode,
      autofocus: autofocus,
      variant: ButtonVariant.secondary,
    );
  }
}
