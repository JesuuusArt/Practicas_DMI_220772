import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/presentation/widgets/video/video_background.dart';
import 'package:toktik/presentation/widgets/video/video_caption.dart';
import 'package:video_player/video_player.dart';

class FullScreenPlayer extends StatefulWidget {

  final VideoPost video;
  final bool isActive;

  const FullScreenPlayer({
    super.key,
    required this.video,
    required this.isActive,
  });

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer> {

  VideoPlayerController? controller;
  Future<void>? _initFuture;
  bool _viewCounted = false;
  bool _showPlayOverlay = false;
  bool _initError = false;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  void _setup() {
    final url = widget.video.videoUrl!;
    controller = widget.video.isAsset
        ? VideoPlayerController.asset(url)
        : VideoPlayerController.networkUrl(
            Uri.parse(url),
            httpHeaders: const {
              'User-Agent': 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
              'Accept': '*/*',
            },
          );
    controller!
      ..setLooping(true)
      ..setVolume(context.read<DiscoverProvider>().muted ? 0 : 1);
    _initFuture = controller!.initialize().then((_) {
      if (widget.isActive) {
        controller!.play();
      }
      if (mounted) setState(() {});
    }).catchError((e) {
      debugPrint('FullScreenPlayer error: $e');
      if (mounted) setState(() => _initError = true);
    });
    if (widget.isActive && !_viewCounted) {
      _viewCounted = true;
      context.read<DiscoverProvider>().addView(widget.video);
    }
  }

  @override
  void didUpdateWidget(covariant FullScreenPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    controller?.setVolume(context.read<DiscoverProvider>().muted ? 0 : 1);

    if (widget.isActive && controller != null && controller!.value.isInitialized) {
      controller!.play();
      if (!_viewCounted) {
        _viewCounted = true;
        context.read<DiscoverProvider>().addView(widget.video);
      }
    } else if (!widget.isActive && controller != null) {
      controller!.pause();
    }
  }

  void _togglePlay() {
    if (controller == null) return;
    setState(() {
      if (controller!.value.isPlaying) {
        controller!.pause();
      } else {
        controller!.play();
      }
      _showPlayOverlay = true;
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _showPlayOverlay = false);
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final muted = context.watch<DiscoverProvider>().muted;
    controller?.setVolume(muted ? 0 : 1);

    if (controller == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (_initError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white60, size: 40),
            const SizedBox(height: 8),
            Text(
              'No se pudo cargar el video',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white60),
            ),
          ],
        ),
      );
    }

    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (snapshot.hasError) {
          return const Center(child: Icon(Icons.error_outline, color: Colors.white60, size: 40));
        }

        return GestureDetector(
          onTap: _togglePlay,
          child: AspectRatio(
            aspectRatio: controller!.value.aspectRatio,
            child: Stack(
              children: [

                VideoPlayer(controller!),

                VideoBackground(
                  stops: const [0.8,1.0],
                ),

                Positioned(
                  bottom: 50,
                  left: 20,
                  child: VideoCaption(caption: widget.video.caption),
                ),

                Center(
                  child: AnimatedOpacity(
                    opacity: _showPlayOverlay ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        );

      },
    );
  }
}
