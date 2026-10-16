import 'dart:async';
import 'package:flutter/material.dart';

class ThemeOverlay extends StatefulWidget {

  final String season;

  const ThemeOverlay({super.key, required this.season});

  @override
  State<ThemeOverlay> createState() => _ThemeOverlayState();
}

class _ThemeOverlayState extends State<ThemeOverlay> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  Timer? _timer;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
    _timer = Timer(const Duration(seconds: 30), () {
      _controller.stop();
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  IconData _iconForSeason() => switch (widget.season) {
    'halloween' => Icons.celebration,
    'navidad' => Icons.ac_unit,
    'valentines' => Icons.favorite,
    _ => Icons.auto_awesome,
  };

  Color _colorForSeason() => switch (widget.season) {
    'halloween' => Colors.orange.withValues(alpha: 0.7),
    'navidad' => Colors.white.withValues(alpha: 0.8),
    'valentines' => Colors.pinkAccent.withValues(alpha: 0.75),
    _ => Colors.purpleAccent.withValues(alpha: 0.5),
  };

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final positions = [0.1, 0.25, 0.4, 0.55, 0.7, 0.85];

    if (!_visible) return const SizedBox.shrink();

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              for (var i = 0; i < positions.length; i++)
                Positioned(
                  left: size.width * positions[i],
                  top: -40 + ((_controller.value + i * 0.17) % 1.0) * (size.height + 80),
                  child: Icon(_iconForSeason(), color: _colorForSeason(), size: 26),
                ),
            ],
          );
        },
      ),
    );
  }
}
