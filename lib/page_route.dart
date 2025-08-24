import 'package:flutter/widgets.dart';

class DesktopPageRoute<T> extends PageRoute<T> {
  DesktopPageRoute({required this.settings, required this.builder});

  @override
  final RouteSettings settings;

  final WidgetBuilder builder;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Duration get reverseTransitionDuration => Duration.zero;
}
