import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toktik/config/theme/app_theme.dart';
import 'package:toktik/config/theme/christmas_theme.dart';
import 'package:toktik/config/theme/halloween_theme.dart';
import 'package:toktik/config/theme/valentines_theme.dart';

class ThemeProvider extends ChangeNotifier {

  static const String _prefKey = 'selected_season_override';

  String _currentSeason = 'navidad';
  String _mode = 'auto';
  final AudioPlayer _audioPlayer = AudioPlayer();

  String get currentSeason => _currentSeason;
  String get mode => _mode;
  bool get isAuto => _mode == 'auto';

  ThemeProvider() {
    _loadSeason();
  }

  static String getAutoSeason() {
    final now = DateTime.now();
    if (now.month == 10) return 'halloween';
    if (now.month == 12) return 'navidad';
    if (now.month == 2) return 'valentines';
    return 'principal';
  }

  Future<void> _loadSeason() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_prefKey) ?? 'navidad';
    _mode = savedMode;
    _currentSeason = (_mode == 'auto') ? getAutoSeason() : _mode;
    _playSeasonSound(_currentSeason);
    notifyListeners();
  }

  Future<void> setSeason(String newMode, {bool playSound = true}) async {
    _mode = newMode;
    _currentSeason = (newMode == 'auto') ? getAutoSeason() : newMode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, newMode);

    if (playSound) {
      _playSeasonSound(_currentSeason);
    }

    notifyListeners();
  }

  void _playSeasonSound(String season) {
    final sound = switch (season) {
      'halloween' => 'sounds/halloween.mp3',
      'navidad' => 'sounds/navidad.mp3',
      'valentines' => 'sounds/valentines.mp3',
      _ => 'sounds/principal.mp3',
    };
    _audioPlayer.stop();
    _audioPlayer.play(AssetSource(sound)).catchError((_) {});
  }

  ThemeData get theme => switch (_currentSeason) {
    'halloween' => HalloweenTheme().getTheme(),
    'navidad' => ChristmasTheme().getTheme(),
    'valentines' => ValentinesTheme().getTheme(),
    _ => AppTheme().getTheme(),
  };

  String get seasonName => switch (_currentSeason) {
    'halloween' => 'Halloween',
    'navidad' => 'Navidad',
    'valentines' => 'San Valentín',
    _ => 'Normal',
  };

  IconData get seasonIcon => switch (_currentSeason) {
    'halloween' => Icons.celebration,
    'navidad' => Icons.ac_unit,
    'valentines' => Icons.favorite,
    _ => Icons.auto_awesome,
  };

  Color get accentColor => switch (_currentSeason) {
    'halloween' => const Color(0xFFFF7518),
    'navidad' => const Color(0xFF2ECC71),
    'valentines' => const Color(0xFFFF2E63),
    _ => const Color(0xFF8E3CC3),
  };

  String get fontName => switch (_currentSeason) {
    'halloween' => 'Creepster',
    'navidad' => 'MountainsOfChristmas',
    'valentines' => 'DancingScript',
    _ => 'Poppins',
  };

  String get iconAsset => switch (_currentSeason) {
    'halloween' => 'assets/icons/halloween.png',
    'navidad' => 'assets/icons/navidad.png',
    'valentines' => 'assets/icons/valentines.png',
    _ => 'assets/icons/principal.png',
  };
}
