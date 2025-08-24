import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sandbox/shortcuts/intents.dart';
import 'package:sandbox/shortcuts/shortcuts_provider.dart';
import '../theme.dart';

/// Controller for the AppTabView that manages the state of the tabs.
class AppTabController extends ChangeNotifier {
  int _selectedIndex;

  AppTabController({int initialIndex = 0}) : _selectedIndex = initialIndex;

  int get selectedIndex => _selectedIndex;
  int length = 0;

  set selectedIndex(int value) {
    if (value != _selectedIndex) {
      _selectedIndex = value;
      notifyListeners();
    }
  }

  void nextTab(int tabCount) {
    selectedIndex = (selectedIndex + 1) % tabCount;
  }

  void previousTab(int tabCount) {
    selectedIndex = (selectedIndex - 1 + tabCount) % tabCount;
  }

  static AppTabController of(BuildContext context) {
    return context.read<AppTabController>();
  }
}

/// Represents a tab with title and content
class AppTab extends Equatable {
  final String title;
  final Widget content;

  const AppTab({required this.title, required this.content});

  @override
  List<Object?> get props => [title, content];
}

class DefaultAppTabController extends StatefulWidget {
  const DefaultAppTabController({super.key, required this.child});

  final Widget child;

  @override
  State<DefaultAppTabController> createState() => _DefaultAppTabControllerState();
}

class _DefaultAppTabControllerState extends State<DefaultAppTabController> {
  late AppTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppTabController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: widget.child,
    );
  }
}

/// Tabbed view that can accept arbitrary widgets as children. Indicates title of the tab
/// and selected tab. Allows to switch between tabs with keyboard shortcuts.
/// Allows to pass custom AppTabController but also instantiates its own if not provided.
/// When selectedTab is changed, the widget rebuilds to reflect the new state.
class AppTabView extends StatefulWidget {
  final List<AppTab> tabs;
  final AppTabController? controller;

  const AppTabView({
    super.key,
    required this.tabs,
    this.controller,
  });

  @override
  State<AppTabView> createState() => _AppTabViewState();
}

class _AppTabViewState extends State<AppTabView> {
  late AppTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? context.read<AppTabController>();

    _controller.addListener(_handleControllerChanged);
    _controller.length = widget.tabs.length;
  }

  @override
  void didUpdateWidget(AppTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_handleControllerChanged);
      _controller = widget.controller ?? _controller;
      _controller.addListener(_handleControllerChanged);
    }
    if (widget.tabs.length != oldWidget.tabs.length) {
      _controller.selectedIndex = 0;
      _controller.length = widget.tabs.length;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }

    super.dispose();
  }

  void _handleControllerChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return ChangeNotifierProvider.value(
      value: _controller,
      child: Actions(
        actions: {
          SelectTabIntent: CallbackAction<SelectTabIntent>(
            onInvoke: (intent) {
              if (intent.tabIndex > 0 && intent.tabIndex <= widget.tabs.length) {
                _controller.selectedIndex = intent.tabIndex - 1;
              }
              return true;
            },
          ),
        },
        child: Shortcuts(
          shortcuts: context.watch<ShortcutsProvider>().getTabIntentShortcuts(),
          child: FocusTraversalGroup(
            onFocusNodeCreated: (focusNode) {
              focusNode.canRequestFocus = false;
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: theme.backgroundColor,
                    border: Border(
                      bottom: BorderSide(
                        color: theme.secondaryColor,
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      for (int i = 0; i < widget.tabs.length; i++)
                        TabHeader(
                          tab: widget.tabs[i],
                          index: i,
                          isSelected: i == _controller.selectedIndex,
                          onTap: () {
                            _controller.selectedIndex = i;
                          },
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: widget.tabs.elementAt(_controller.selectedIndex).content,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TabHeader extends StatefulWidget {
  final AppTab tab;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const TabHeader({
    super.key,
    required this.tab,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<TabHeader> createState() => _TabHeaderState();
}

class _TabHeaderState extends State<TabHeader> {
  bool isHovered = false;
  bool isFocused = false;
  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'TabHeader_${widget.tab.title}');
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    var color = switch ((isHovered, isFocused, widget.isSelected)) {
      (true, _, _) => theme.secondaryColor,
      (_, true, _) => theme.secondaryColor.withValues(alpha: 0.5),
      (_, _, true) => theme.backgroundColor,
      _ => Colors.transparent,
    };
    return GestureDetector(
      onTap: widget.onTap,
      child: FocusableActionDetector(
        focusNode: _focusNode,
        onFocusChange: (hasFocus) {
          setState(() {
            isFocused = hasFocus;
          });
        },
        onShowHoverHighlight: (hovering) {
          setState(() {
            isHovered = hovering;
          });
        },
        descendantsAreFocusable: false,
        descendantsAreTraversable: false,
        actions: {
          ActivateIntent: CallbackAction<Intent>(
            onInvoke: (intent) {
              widget.onTap();
              return null;
            },
          ),
        },
        shortcuts: {
          LogicalKeySet(LogicalKeyboardKey.enter): ActivateIntent(),
          LogicalKeySet(LogicalKeyboardKey.space): ActivateIntent(),

          LogicalKeySet(LogicalKeyboardKey.tab): NextFocusIntent(),
          LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab): PreviousFocusIntent(),
        },

        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: theme.defaultSpacing * 2,
            vertical: theme.defaultSpacing,
          ),
          decoration: BoxDecoration(
            color: color,
          ),
          child: Text(
            widget.tab.title,
            style: theme.paragraphStyle.copyWith(
              fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
