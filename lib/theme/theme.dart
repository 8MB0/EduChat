import 'package:flutter/material.dart';

class MyTheme {
  static ThemeData appTheme(BuildContext context) => ThemeData(
        brightness: Brightness.dark,
        iconTheme: const IconThemeData(color: Colors.white),
        appBarTheme: const AppBarTheme(
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent, 
        ),
        colorScheme: ColorScheme.fromSwatch(
          brightness: Brightness.dark,
        ).copyWith(
          surface: backgroundColour,
          secondary: accentColour,
        ),
      );

  static const Color accentColour = Color(0xFF2664C6);
  static const Color backgroundColour = Color(0xff1d1b25);

  static Widget appBarGradient({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}
