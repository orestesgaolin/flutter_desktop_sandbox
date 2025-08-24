import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sandbox/colors.dart';
import 'package:sandbox/page_route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'Flutter Demo',
      color: Colors.black,
      routes: <String, WidgetBuilder>{
        '/': (context) => MyHomePage(),
      },
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
      ),
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyP): ActivateIntent(),
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (ActivateIntent intent) {
            debugPrint('Meta+P pressed');
            return null;
          },
        ),
      },
      pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) => PageRouteBuilder<T>(
        settings: settings,
        pageBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) => builder(context),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit.'),
        ],
      ),
    );
  }
}
