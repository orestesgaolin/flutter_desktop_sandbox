import 'package:flutter/widgets.dart';
import 'package:sandbox/theme.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    this.padding = const EdgeInsets.all(16),
    required this.child,
    this.scrollable = true,
  });
  final EdgeInsets padding;
  final Widget child;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.of(context).backgroundColor,
      ),
      child: scrollable
          ? SingleChildScrollView(
              padding: padding,
              child: child,
            )
          : Padding(
              padding: padding,
              child: child,
            ),
    );
  }
}
