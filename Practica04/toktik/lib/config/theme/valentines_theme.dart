import 'package:flutter/material.dart';

class ValentinesTheme {

  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'DancingScript',
    scaffoldBackgroundColor: const Color(0xFF1F0B14),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF2E63),
      brightness: Brightness.dark,
    ),
  );

}
