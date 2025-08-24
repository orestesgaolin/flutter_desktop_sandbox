import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sandbox/theme.dart';

/// Generic Dropdown widget avoiding usage of material components
/// Uses overlay to display dropdown items in a ListView
class AppDropdown<T> extends StatefulWidget {
  const AppDropdown({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.header,
    this.value,
    this.onChanged,
    this.maxHeight = 300.0,
    this.width,
  });

  /// List of items to display in the dropdown
  final List<T> items;

  /// How to render each item in the dropdown
  final Widget Function(T item) itemBuilder;

  /// Current selected value
  final T? value;

  /// Callback when a new value is selected
  final ValueChanged<T>? onChanged;

  /// Widget to display when dropdown is closed (typically shows the selected value)
  final Widget header;

  /// Dropdown menu max height
  final double? maxHeight;

  /// Dropdown menu width, defaults to the width of the header widget
  final double? width;

  @override
  State<AppDropdown<T>> createState() => _AppDropdownState<T>();
}

class _AppDropdownState<T> extends State<AppDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  bool _isFocused = false;
  bool _isHovered = false;
  FocusNode? _focusNode;
  List<FocusNode> _itemFocusNodes = [];

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode!.addListener(() {
      print('FocusNode listener: hasFocus=${_focusNode!.hasFocus}');
    });
    _itemFocusNodes = widget.items.map((e) => FocusNode()).toList();
  }

  @override
  void didUpdateWidget(covariant AppDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _itemFocusNodes.forEach((node) => node.dispose());
      _itemFocusNodes = widget.items.map((e) => FocusNode()).toList();
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode?.dispose();
    _itemFocusNodes.forEach((node) => node.dispose());
    super.dispose();
  }

  void _toggleDropdown({bool fromAction = false}) {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _focusNode?.requestFocus();
      _showOverlay();
      if (fromAction && _itemFocusNodes.isNotEmpty) {
        _itemFocusNodes.first.requestFocus();
      }
    }
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry() {
    // Calculate render box to position overlay correctly
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: widget.width ?? size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height),
          child: _buildDropdownMenu(),
        ),
      ),
    );
  }

  Widget _buildDropdownMenu() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: widget.maxHeight!,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(16, 0, 0, 0),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: widget.items.map((item) {
          final focusNode = _itemFocusNodes[widget.items.indexOf(item)];
          return AppDropdownMenuItem(
            builder: (context) => widget.itemBuilder(item),
            focusNode: focusNode,
            onTap: () {
              widget.onChanged?.call(item);
              _toggleDropdown();
            },
            onDismiss: () {
              _toggleDropdown();
              _focusNode?.requestFocus();
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColorBase = Color.fromARGB(10, 0, 0, 0);
    final focusBorderColor = Color.fromARGB(40, 0, 0, 0);
    final hoverBorderColor = Color.fromARGB(20, 0, 0, 0);
    final focusColor = Color.fromARGB(20, 0, 0, 0);
    final hoverColor = Color.fromARGB(10, 0, 0, 0);
    final borderColor = switch ((_isHovered, _isFocused, _isOpen)) {
      (true, _, _) => hoverBorderColor,
      (_, true, _) => focusBorderColor,
      (_, _, true) => borderColorBase,
      _ => borderColorBase,
    };
    final backgroundColor = switch ((_isHovered, _isFocused, _isOpen)) {
      (true, _, _) => hoverColor,
      (_, true, _) => focusColor,
      (_, _, true) => null,
      _ => null,
    };
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: FocusableActionDetector(
          focusNode: _focusNode,
          onFocusChange: (hasFocus) {
            setState(() {
              _isFocused = hasFocus;
            });
          },
          onShowHoverHighlight: (hovering) {
            setState(() {
              _isHovered = hovering;
            });
          },
          shortcuts: {
            LogicalKeySet(LogicalKeyboardKey.enter): ActivateIntent(),
            LogicalKeySet(LogicalKeyboardKey.space): ActivateIntent(),
            LogicalKeySet(LogicalKeyboardKey.escape): DismissIntent(),
          },
          descendantsAreFocusable: false,
          descendantsAreTraversable: false,
          actions: {
            ActivateIntent: CallbackAction<Intent>(
              onInvoke: (intent) {
                print('ActivateAction - dropdown');
                _toggleDropdown(fromAction: true);
                return true;
              },
            ),
            if (_isOpen)
              DismissIntent: CallbackAction<Intent>(
                onInvoke: (intent) {
                  print('DismissAction - dropdown');
                  if (_isOpen) {
                    _toggleDropdown();
                    return true;
                  }
                },
              ),
          },
          mouseCursor: SystemMouseCursors.click,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: widget.header,
          ),
        ),
      ),
    );
  }
}

class AppDropdownMenuItem extends StatefulWidget {
  const AppDropdownMenuItem({
    super.key,
    required this.builder,
    this.onTap,
    this.onDismiss,
    required this.focusNode,
  });

  final WidgetBuilder builder;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final FocusNode focusNode;

  @override
  State<AppDropdownMenuItem> createState() => _AppDropdownMenuItemState();
}

class _AppDropdownMenuItemState extends State<AppDropdownMenuItem> {
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final color = switch ((_isHovered, _isFocused)) {
      (true, _) => const Color(0xFFE0E0E0),
      (_, true) => const Color(0xFFE0E0E0),
      _ => const Color(0xFFF5F5F5),
    };
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: FocusableActionDetector(
        focusNode: widget.focusNode,
        onShowHoverHighlight: (isHovered) {
          setState(() {
            _isHovered = isHovered;
          });
        },
        onFocusChange: (isFocused) {
          setState(() {
            _isFocused = isFocused;
          });
        },
        descendantsAreFocusable: false,
        descendantsAreTraversable: false,
        mouseCursor: SystemMouseCursors.click,
        actions: {
          ActivateIntent: CallbackAction<Intent>(
            onInvoke: (intent) {
              print('ActivateAction - dropdown item');
              widget.onTap?.call();
              return true;
            },
          ),
          DismissIntent: CallbackAction<Intent>(
            onInvoke: (intent) {
              print('DismissAction - dropdown item');
              widget.onDismiss?.call();

              return true;
            },
          ),
        },
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.enter): ActivateIntent(),
          LogicalKeySet(LogicalKeyboardKey.space): ActivateIntent(),
          LogicalKeySet(LogicalKeyboardKey.escape): DismissIntent(),
        },

        child: Container(
          color: color,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: widget.builder(context),
        ),
      ),
    );
  }
}
