import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sandbox/theme.dart';
import 'package:sandbox/page_route.dart';
import 'package:sandbox/shortcuts/intents.dart';
import 'package:sandbox/shortcuts/shortcuts_manager_page.dart';
import 'package:sandbox/shortcuts/shortcuts_provider.dart';
import 'package:sandbox/widgets/tab_view.dart';
import 'package:sandbox/widgets/widgets.dart';

void main() {
  final shortcutsProvider = ShortcutsProvider(
    initialShortcuts: [],
  );
  runApp(
    MyApp(
      shortcutsProvider: shortcutsProvider,
    ),
  );
}

final globalKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.shortcutsProvider,
  });

  final ShortcutsProvider shortcutsProvider;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: shortcutsProvider,
      child: DefaultAppTabController(
        child: DefaultTextEditingShortcuts(
          child: AppThemeInherited(
            theme: AppTheme.light(),
            child: Builder(
              builder: (context) {
                final shortcutsProvider = context.watch<ShortcutsProvider>();
                return FocusScopeListener(
                  child: WidgetsApp(
                    title: 'Desktop Demo',
                    color: AppTheme.of(context).backgroundColor,
                    navigatorKey: globalKey,
                    routes: <String, WidgetBuilder>{
                      '/': (context) => MyHomePage(),
                      '/settings': (context) => ShortcutsManagerPage(),
                    },
                    onUnknownRoute: (RouteSettings settings) {
                      return DesktopPageRoute(
                        settings: settings,
                        builder: (context) => ColoredBox(
                          color: AppTheme.of(context).backgroundColor,
                          child: Center(
                            child: Text(
                              '404 - Page not found',
                              style: AppTheme.of(context).paragraphStyle,
                            ),
                          ),
                        ),
                      );
                    },
                    textStyle: AppTheme.of(context).paragraphStyle,
                    shortcuts: {
                      ...WidgetsApp.defaultShortcuts,
                      LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyP): ActivateIntent(),
                      LogicalKeySet(LogicalKeyboardKey.escape): DismissIntent(),
                      ...shortcutsProvider.getShortcutsMap(),
                    },
                    actions: <Type, Action<Intent>>{
                      ...WidgetsApp.defaultActions,
                      DismissIntent: CallbackAction<DismissIntent>(
                        onInvoke: (DismissIntent intent) {
                          print('DismissIntent - top');
                          FocusScope.of(context).unfocus();
                          return true;
                        },
                      ),
                      OpenSettingsIntent: CallbackAction<OpenSettingsIntent>(
                        onInvoke: (OpenSettingsIntent intent) {
                          debugPrint('Opening settings');
                          globalKey.currentState?.pushNamed('/settings');
                          return true;
                        },
                      ),
                      ShowCommandPaletteIntent: CallbackAction<ShowCommandPaletteIntent>(
                        onInvoke: (ShowCommandPaletteIntent intent) {
                          debugPrint('Showing command palette');
                          return true;
                        },
                      ),
                      OpenNewTabIntent: CallbackAction<OpenNewTabIntent>(
                        onInvoke: (OpenNewTabIntent intent) {
                          debugPrint('Opening new tab');
                          return true;
                        },
                      ),
                      GoBackIntent: CallbackAction<GoBackIntent>(
                        onInvoke: (GoBackIntent intent) {
                          debugPrint('Going back');
                          globalKey.currentState?.maybePop();
                          return true;
                        },
                      ),
                      SelectTabIntent: CallbackAction<SelectTabIntent>(
                        onInvoke: (intent) {
                          print('SelectTabIntent - ${intent.tabIndex}');
                          final controller = AppTabController.of(context);
                          if (intent.tabIndex > 0 && intent.tabIndex <= controller.length) {
                            controller.selectedIndex = intent.tabIndex - 1;
                          }
                          return true;
                        },
                      ),
                      TypeDigitIntent: CallbackAction<TypeDigitIntent>(
                        onInvoke: (TypeDigitIntent intent) {
                          print('TypeDigitIntent - ${intent.digit}');
                          
                          _showTypedCharacterOverlay(globalKey.currentState?.overlay, intent.digit.toString());
                          return false;
                        },
                      ),
                    },
                    pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) => DesktopPageRoute(
                      settings: settings,
                      builder: builder,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return AppTabView(
      tabs: const [
        AppTab(
          title: 'Home',
          content: ShowcasePage(),
        ),
        AppTab(
          title: 'Settings',
          content: ShortcutsManagerPage(),
        ),
      ],
    );
  }
}

class ShowcasePage extends StatelessWidget {
  const ShowcasePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppPage(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: AppTheme.of(context).defaultSpacing,
          children: <Widget>[
            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
            ),
            AppTextField(),
            AppTextField(),
            AppTextField(),
            AppButton(
              onPressed: () {},
              label: 'Primary Button',
            ),
            SecondaryButton(
              onPressed: () {},
              label: 'Secondary Button',
            ),
          ],
        ),
      ),
    );
  }
}

class FocusScopeListener extends StatefulWidget {
  const FocusScopeListener({super.key, required this.child});

  final Widget child;

  @override
  State<FocusScopeListener> createState() => _FocusScopeListenerState();
}

class _FocusScopeListenerState extends State<FocusScopeListener> {
  FocusNode? _currentFocus;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_focusChangeListener);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_focusChangeListener);
    super.dispose();
  }

  void _focusChangeListener() {
    _currentFocus = FocusManager.instance.primaryFocus;
    print('Focus changed: ${_currentFocus?.debugLabel}');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          Positioned.fill(child: widget.child),
          Positioned(
            bottom: 16,
            left: 16,
            child: Text(
              _currentFocus?.debugLabel ?? 'No Focus',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

/// Overlay to show typed character
/// This overlay will display the character being typed by the user
void _showTypedCharacterOverlay(OverlayState? overlayState, String character) {
  if (overlayState == null) return;

  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
          ),  
          child: Center(
            child: Text(
              character,
              style: TextStyle(
                fontSize: 36,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  overlayState.insert(overlayEntry);
  Future.delayed(Duration(seconds: 1), () {
    overlayEntry.remove();
  });
}
