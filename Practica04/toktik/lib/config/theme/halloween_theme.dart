import 'package:flutter/material.dart';

class HalloweenTheme {

  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Creepster',
    scaffoldBackgroundColor: const Color(0xFF14080A),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF7518),
      brightness: Brightness.dark,
    ),
  );

}
