import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/config/theme/app_theme.dart';
import 'package:toktik/config/theme/halloween_theme.dart';
import 'package:toktik/config/theme/christmas_theme.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/presentation/screens/discover/discover_screen.dart';

// Tema manual: pon 'principal', 'halloween' o 'navidad' para forzarlo,
// o déjalo en null para que use el tema automático según la fecha.
const String manualSeason = 'principal';

String autoSeason() {
  final now = DateTime.now();
  if (now.month == 10) return 'halloween'; // Octubre
  if (now.month == 12) return 'navidad';   // Diciembre
  return 'principal';
}

final seasonTheme = switch (manualSeason ?? autoSeason()) {
  'halloween' => HalloweenTheme().getTheme(),
  'navidad' => ChristmasTheme().getTheme(),
  _ => AppTheme().getTheme(),
};

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider( 
          lazy: false,
          create: (_) => DiscoverProvider()..loadNextPage() 
        ),
      ],
      child: MaterialApp(
        title: 'TokTik',
        debugShowCheckedModeBanner: false,
        theme: seasonTheme,
        home: const DiscoverScreen()
      ),
    );
  }
}