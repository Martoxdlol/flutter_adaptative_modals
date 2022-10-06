import 'package:flutter/material.dart';

final darkTheme = ThemeData(
  primarySwatch: Colors.indigo,
  colorScheme: ColorScheme.dark(),
);

final lightTheme = ThemeData(
  primarySwatch: Colors.indigo,
  colorScheme: ColorScheme.light(),
);

class ThemeSwitcher extends InheritedWidget {
  final _ThemeSwitcherWidgetState data;

  const ThemeSwitcher({
    super.key,
    required this.data,
    required Widget child,
  }) : super(child: child);

  static _ThemeSwitcherWidgetState of(BuildContext context) {
    return (context.dependOnInheritedWidgetOfExactType<ThemeSwitcher>() as ThemeSwitcher).data;
  }

  @override
  bool updateShouldNotify(ThemeSwitcher old) {
    return this != old;
  }
}

class ThemeSwitcherWidget extends StatefulWidget {
  final ThemeData initialTheme;
  final Widget child;

  ThemeSwitcherWidget({super.key, required this.initialTheme, required this.child});

  @override
  _ThemeSwitcherWidgetState createState() => _ThemeSwitcherWidgetState();
}

class _ThemeSwitcherWidgetState extends State<ThemeSwitcherWidget> {
  ThemeData? themeData;

  void switchTheme(ThemeData theme) {
    setState(() {
      themeData = theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    themeData = themeData ?? widget.initialTheme;
    return ThemeSwitcher(
      data: this,
      child: widget.child,
    );
  }
}
