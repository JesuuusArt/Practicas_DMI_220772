import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/presentation/providers/theme_provider.dart';
import 'package:toktik/presentation/widgets/shared/theme_overlay.dart';
import 'package:toktik/presentation/widgets/shared/video_scrollable_view.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> with SingleTickerProviderStateMixin {

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showSeasonSelector(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    'Mecanismo de Prueba: Temporada',
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Elige una temporada para forzarla o usa la fecha del dispositivo (Guardado en Local Storage):',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  _SeasonOptionTile(
                    title: 'Automático (Por fecha del dispositivo)',
                    subtitle: 'Mes actual determina el tema',
                    icon: Icons.calendar_today,
                    selected: themeProvider.mode == 'auto',
                    onTap: () {
                      themeProvider.setSeason('auto');
                      Navigator.pop(ctx);
                    },
                  ),
                  _SeasonOptionTile(
                    title: 'Halloween (Octubre)',
                    subtitle: 'Fuente Creepster, audio e icono de calabaza',
                    imageAsset: 'assets/icons/halloween.png',
                    color: const Color(0xFFFF7518),
                    selected: themeProvider.mode == 'halloween',
                    onTap: () {
                      themeProvider.setSeason('halloween');
                      Navigator.pop(ctx);
                    },
                  ),
                  _SeasonOptionTile(
                    title: 'Navidad (Diciembre)',
                    subtitle: 'Fuente Mountains of Christmas, campanas y nieve',
                    imageAsset: 'assets/icons/navidad.png',
                    color: const Color(0xFF2ECC71),
                    selected: themeProvider.mode == 'navidad',
                    onTap: () {
                      themeProvider.setSeason('navidad');
                      Navigator.pop(ctx);
                    },
                  ),
                  _SeasonOptionTile(
                    title: 'San Valentín (Febrero)',
                    subtitle: 'Fuente Dancing Script, corazones y romance',
                    imageAsset: 'assets/icons/valentines.png',
                    color: const Color(0xFFFF2E63),
                    selected: themeProvider.mode == 'valentines',
                    onTap: () {
                      themeProvider.setSeason('valentines');
                      Navigator.pop(ctx);
                    },
                  ),
                  _SeasonOptionTile(
                    title: 'Normal (Predeterminado)',
                    subtitle: 'Fuente Poppins y paleta púrpura',
                    imageAsset: 'assets/icons/principal.png',
                    color: const Color(0xFF8E3CC3),
                    selected: themeProvider.mode == 'principal',
                    onTap: () {
                      themeProvider.setSeason('principal');
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final discoverProvider = context.watch<DiscoverProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      body: discoverProvider.initialLoading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : Stack(
              children: [
                Column(
                  children: [
                    SafeArea(
                      bottom: false,
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.35),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            _ToktikBadge(onTap: () => _showSeasonSelector(context)),
                            Expanded(
                              child: TabBar(
                                controller: _tabController,
                                isScrollable: false,
                                labelColor: Colors.white,
                                unselectedLabelColor: Colors.white54,
                                indicatorColor: themeProvider.accentColor,
                                indicatorWeight: 2.5,
                                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                tabs: const [
                                  Tab(text: 'Para ti'),
                                  Tab(text: 'Descubrir'),
                                  Tab(text: 'Favoritos'),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showSeasonSelector(context),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: themeProvider.accentColor, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: themeProvider.accentColor.withValues(alpha: 0.35),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    themeProvider.iconAsset,
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Icon(themeProvider.seasonIcon, color: themeProvider.accentColor, size: 20),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _VideoTab(videos: discoverProvider.forYouVideos),
                          _DiscoverTab(provider: discoverProvider),
                          _VideoTab(
                            videos: discoverProvider.favoriteVideos,
                            emptyMessage: 'No tienes videos favoritos aún.\n¡Toca el corazón (❤️) en cualquier video para guardarlo aquí!',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ThemeOverlay(season: themeProvider.currentSeason),
              ],
            ),
    );
  }
}

class _DiscoverTab extends StatefulWidget {
  final DiscoverProvider provider;

  const _DiscoverTab({required this.provider});

  @override
  State<_DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<_DiscoverTab> {
  String _selectedFilter = 'Todos';

  @override
  Widget build(BuildContext context) {
    final List<VideoPost> filteredVideos = switch (_selectedFilter) {
      'YouTube' => widget.provider.youtubeVideos,
      'Pixabay' => widget.provider.pixabayVideos,
      'Coverr' => widget.provider.coverrVideos,
      _ => widget.provider.discoverVideos,
    };

    return Stack(
      children: [
        _VideoTab(
          videos: filteredVideos,
          emptyMessage: 'No hay videos disponibles para $_selectedFilter',
        ),
        Positioned(
          top: 8,
          left: 12,
          right: 12,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Todos (${widget.provider.discoverVideos.length})',
                  selected: _selectedFilter == 'Todos',
                  onTap: () => setState(() => _selectedFilter = 'Todos'),
                ),
                const SizedBox(width: 6),
                _FilterChip(
                  label: 'YouTube (${widget.provider.youtubeVideos.length})',
                  icon: Icons.play_circle_fill,
                  iconColor: Colors.redAccent,
                  selected: _selectedFilter == 'YouTube',
                  onTap: () => setState(() => _selectedFilter = 'YouTube'),
                ),
                const SizedBox(width: 6),
                _FilterChip(
                  label: 'Pixabay (${widget.provider.pixabayVideos.length})',
                  icon: Icons.video_library,
                  iconColor: Colors.greenAccent,
                  selected: _selectedFilter == 'Pixabay',
                  onTap: () => setState(() => _selectedFilter = 'Pixabay'),
                ),
                const SizedBox(width: 6),
                _FilterChip(
                  label: 'Coverr (${widget.provider.coverrVideos.length})',
                  icon: Icons.ondemand_video,
                  iconColor: Colors.lightBlueAccent,
                  selected: _selectedFilter == 'Coverr',
                  onTap: () => setState(() => _selectedFilter = 'Coverr'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? iconColor;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    this.iconColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withValues(alpha: 0.9)
              : Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.white : Colors.white30,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: selected ? Colors.black87 : (iconColor ?? Colors.white)),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.black : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeasonOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? imageAsset;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  const _SeasonOptionTile({
    required this.title,
    required this.subtitle,
    this.icon,
    this.imageAsset,
    this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.white;

    return ListTile(
      dense: true,
      onTap: onTap,
      leading: imageAsset != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(imageAsset!, width: 28, height: 28, fit: BoxFit.cover),
            )
          : Icon(icon ?? Icons.auto_awesome, color: effectiveColor),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? effectiveColor : Colors.white,
          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      trailing: selected ? Icon(Icons.check, color: effectiveColor) : null,
    );
  }
}

class _VideoTab extends StatelessWidget {
  final List<VideoPost> videos;
  final String? emptyMessage;

  const _VideoTab({required this.videos, this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.video_library_outlined, size: 44, color: Colors.white38),
              const SizedBox(height: 12),
              Text(
                emptyMessage ?? 'No hay videos disponibles',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white60),
              ),
            ],
          ),
        ),
      );
    }
    return VideoScrollableView(videos: videos);
  }
}

class _ToktikBadge extends StatelessWidget {
  final VoidCallback onTap;

  const _ToktikBadge({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final accent = themeProvider.accentColor;
    final font = themeProvider.fontName;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withValues(alpha: 0.7), width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.asset(
                themeProvider.iconAsset,
                width: 18,
                height: 18,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(themeProvider.seasonIcon, color: accent, size: 16),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'TokTik',
              style: TextStyle(
                fontFamily: font,
                color: accent,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
