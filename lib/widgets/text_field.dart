import 'package:flutter/cupertino.dart' show cupertinoDesktopTextSelectionHandleControls;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show AdaptiveTextSelectionToolbar;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sandbox/theme.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController controller;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? TextEditingController();
    focusNode = widget.focusNode ?? FocusNode(debugLabel: 'AppTextField');
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  static Widget _defaultContextMenuBuilder(
    BuildContext context,
    EditableTextState editableTextState,
  ) {
    if (SystemContextMenu.isSupportedByField(editableTextState)) {
      return SystemContextMenu.editableText(editableTextState: editableTextState);
    }
    return AdaptiveTextSelectionToolbar.editableText(editableTextState: editableTextState);
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);
    TextSelectionControls? textSelectionControls;
    final bool paintCursorAboveText;
    bool? cursorOpacityAnimates;
    Offset? cursorOffset;
    final Color cursorColor;
    final Color selectionColor;
    Color? autocorrectionTextRectColor;

    VoidCallback? handleDidGainAccessibilityFocus;
    VoidCallback? handleDidLoseAccessibilityFocus;
    const iOSHorizontalOffset = -2;

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        throw UnimplementedError();

      case TargetPlatform.macOS:
        textSelectionControls ??= cupertinoDesktopTextSelectionHandleControls;
        paintCursorAboveText = true;
        cursorOpacityAnimates ??= false;
        cursorColor = appTheme.textFieldCursorColor;
        selectionColor = appTheme.textFieldSelectionColor;
        cursorOffset = Offset(iOSHorizontalOffset / MediaQuery.devicePixelRatioOf(context), 0);
        handleDidGainAccessibilityFocus = () {
          // Automatically activate the TextField when it receives accessibility focus.
          if (!focusNode.hasFocus && focusNode.canRequestFocus) {
            focusNode.requestFocus();
          }
        };
        handleDidLoseAccessibilityFocus = () {
          focusNode.unfocus();
        };

      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        throw UnimplementedError();
      case TargetPlatform.linux:
        throw UnimplementedError();
      case TargetPlatform.windows:
        throw UnimplementedError();
    }

    return Semantics(
      onDidGainAccessibilityFocus: handleDidGainAccessibilityFocus,
      onDidLoseAccessibilityFocus: handleDidLoseAccessibilityFocus,
      child: RepaintBoundary(
        child: DecoratedBox(
          decoration: appTheme.textFieldDecoration,
          child: Actions(
            actions: {
              DismissIntent: CallbackAction<DismissIntent>(
                onInvoke: (DismissIntent intent) {
                  print('DismissIntent - TextField');
                  FocusScope.of(context).unfocus();
                  return true;
                },
              ),
            },
            child: EditableText(
              controller: controller,
              focusNode: focusNode,
              style: appTheme.textFieldStyle,
              cursorColor: cursorColor,
              backgroundCursorColor: cursorColor,
              contextMenuBuilder: _defaultContextMenuBuilder,
              selectionControls: textSelectionControls,
              selectionColor: selectionColor,
              enableInteractiveSelection: true,
              autocorrectionTextRectColor: autocorrectionTextRectColor,
              paintCursorAboveText: paintCursorAboveText,
              showSelectionHandles: true,
              cursorOffset: cursorOffset,
            ),
          ),
        ),
      ),
    );
  }
}
