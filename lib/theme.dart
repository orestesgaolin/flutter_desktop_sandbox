import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

// inherited widget
class AppThemeInherited extends InheritedWidget {
  const AppThemeInherited({
    super.key,
    required super.child,
    required this.theme,
  });

  final AppTheme theme;

  static AppThemeInherited of(BuildContext context) {
    final AppThemeInherited? result = context.dependOnInheritedWidgetOfExactType<AppThemeInherited>();
    assert(result != null, 'No AppThemeInherited found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    if (oldWidget is AppThemeInherited) {
      return oldWidget.theme != theme;
    }
    return true;
  }
}

class AppTheme extends Equatable {
  const AppTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.paragraphStyle,
    required this.textFieldStyle,
    required this.textFieldDecoration,
    required this.textFieldCursorColor,
    required this.textFieldSelectionColor,
    required this.defaultSpacing,
    required this.cardDecoration,
    required this.tabActiveColor,
    required this.tabInactiveColor,
    required this.buttonTheme,
  });

  AppTheme.light()
    : this(
        primaryColor: Colors.black,
        secondaryColor: Colors.lightGrey,
        backgroundColor: Colors.white,
        paragraphStyle: const TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),
        textFieldStyle: const TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),
        textFieldDecoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color.fromARGB(141, 0, 0, 0),
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        textFieldCursorColor: Colors.black,
        textFieldSelectionColor: const Color.fromARGB(78, 0, 0, 0),
        defaultSpacing: 8.0,
        cardDecoration: _defaultCardDecoration,
        tabActiveColor: Colors.white,
        tabInactiveColor: const Color.fromARGB(20, 0, 0, 0),
        buttonTheme: const AppButtonTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey,
          disabledForegroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          borderRadius: 8.0,
        ),
      );

  static final BoxDecoration _defaultCardDecoration = BoxDecoration(
    color: Colors.white,
    border: Border.all(
      color: Colors.lightGrey,
      width: 0.5,
    ),
    borderRadius: BorderRadius.circular(4),
  );

  BoxDecoration dynamicCardDecoration({
    bool focused = false,
    bool hovered = false,
  }) {
    final borderColorBase = Color.fromARGB(50, 0, 0, 0);
    final focusBorderColor = Color.fromARGB(60, 0, 0, 0);
    final hoverBorderColor = Color.fromARGB(20, 0, 0, 0);
    final focusColor = Color.fromARGB(20, 0, 0, 0);
    final hoverColor = Color.fromARGB(10, 0, 0, 0);
    final borderColor = switch ((hovered, focused)) {
      (true, _) => hoverBorderColor,
      (_, true) => focusBorderColor,
      _ => borderColorBase,
    };
    final backgroundColor = switch ((hovered, focused)) {
      (true, _) => hoverColor,
      (_, true) => focusColor,
      (_, _) => null,
    };
    return BoxDecoration(
      color: backgroundColor ?? _defaultCardDecoration.color,
      border: Border.all(
        color: borderColor,
        width: 0.5,
      ),
      borderRadius: BorderRadius.circular(4),
    );
  }

  static AppTheme of(BuildContext context) {
    return AppThemeInherited.of(context).theme;
  }

  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final TextStyle paragraphStyle;
  final TextStyle textFieldStyle;
  final Decoration textFieldDecoration;
  final Color textFieldCursorColor;
  final Color textFieldSelectionColor;
  final double defaultSpacing;
  final Decoration cardDecoration;
  final Color tabActiveColor;
  final Color tabInactiveColor;
  final AppButtonTheme buttonTheme;

  @override
  List<Object?> get props => [
    primaryColor,
    secondaryColor,
    backgroundColor,
    paragraphStyle,
    textFieldStyle,
    textFieldDecoration,
    textFieldCursorColor,
    textFieldSelectionColor,
    defaultSpacing,
    cardDecoration,
    tabActiveColor,
    tabInactiveColor,
    buttonTheme,
  ];
}

class AppButtonTheme extends Equatable {
  const AppButtonTheme({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.disabledBackgroundColor,
    required this.disabledForegroundColor,
    required this.padding,
    required this.borderRadius,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Color disabledBackgroundColor;
  final Color disabledForegroundColor;
  final EdgeInsets padding;
  final double borderRadius;

  static AppButtonTheme of(BuildContext context) {
    return AppTheme.of(context).buttonTheme;
  }

  @override
  List<Object?> get props => [
    backgroundColor,
    foregroundColor,
    disabledBackgroundColor,
    disabledForegroundColor,
    padding,
    borderRadius,
  ];
}

class Colors {
  static const Color red = Color(0xFFFF0000);
  static const Color green = Color(0xFF00FF00);
  static const Color blue = Color(0xFF0000FF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF808080);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);
}
