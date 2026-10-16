import 'package:flutter/material.dart';

class AppTheme {

  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF8E3CC3),
      brightness: Brightness.dark,
    ),
  );

}
