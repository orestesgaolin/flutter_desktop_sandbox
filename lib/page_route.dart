import 'package:flutter/widgets.dart';

class DesktopPageRoute<T> extends PageRoute<T> {
  DesktopPageRoute({required this.settings, required this.builder});

  @override
  final RouteSettings settings;

  final WidgetBuilder builder;

  @override
  Widget buildContent(BuildContext context) {
    return builder(context);
  }

  @override
  Color? get barrierColor => throw UnimplementedError();

  @override
  String? get barrierLabel => throw UnimplementedError();

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
  Duration get transitionDuration => const Duration(milliseconds: 150);
}
