const String manualSeason = ''; // '' para automático, o 'principal' | 'halloween' | 'navidad'

String currentSeason() {
  if (manualSeason.isNotEmpty) return manualSeason;
  final now = DateTime.now();
  if (now.month == 10) return 'halloween';
  if (now.month == 12) return 'navidad';
  if (now.month == 2) return 'valentines';
  return 'principal';
}
