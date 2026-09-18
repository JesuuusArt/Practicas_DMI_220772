import 'package:flutter/material.dart';

const Color _customColor = Color.fromARGB(255, 158, 55, 158);

const List<Color> colorTheme = [
  _customColor,
  Colors.blue,
  Colors.teal,
  Colors.green,
  Colors.yellow,
  Colors.orange,
  Colors.pink,
];

class AppTheme {
  final int selectedColor;

  AppTheme({this.selectedColor = 0})
      : assert(
          selectedColor >= 0 && selectedColor < colorTheme.length,
          'Color must be between 0 and ${colorTheme.length - 1}',
        );

  ThemeData theme() {
    return ThemeData(
      colorSchemeSeed: colorTheme[selectedColor],
    );
  }
}
