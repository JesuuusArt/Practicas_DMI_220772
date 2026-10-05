import 'package:flutter/material.dart';

class ChristmasTheme {

  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'MountainsOfChristmas',
    scaffoldBackgroundColor: const Color(0xFF0C3317),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFC41E3A),
      brightness: Brightness.dark,
    ),
  );

}
