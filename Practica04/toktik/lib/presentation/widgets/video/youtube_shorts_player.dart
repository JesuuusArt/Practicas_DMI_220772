import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/presentation/widgets/video/video_background.dart';
import 'package:toktik/presentation/widgets/video/video_caption.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeShortsPlayer extends StatefulWidget {

  final VideoPost video;
  final bool isActive;

  const YoutubeShortsPlayer({
    super.key,
    required this.video,
    required this.isActive,
  });

  @override
  State<YoutubeShortsPlayer> createState() => _YoutubeShortsPlayerState();
}

class _YoutubeShortsPlayerState extends State<YoutubeShortsPlayer> {

  late YoutubePlayerController _controller;
  bool _viewCounted = false;

  @override
  void initState() {
    super.initState();
    final initialMuted = context.read<DiscoverProvider>().muted;
    _controller = YoutubePlayerController(
      initialVideoId: widget.video.youtubeId!,
      flags: YoutubePlayerFlags(
        autoPlay: widget.isActive,
        mute: initialMuted,
        loop: true,
        showLiveFullscreenButton: false,
      ),
    );
    if (widget.isActive && !_viewCounted) {
      _viewCounted = true;
      context.read<DiscoverProvider>().addView(widget.video);
    }
  }

  @override
  void didUpdateWidget(covariant YoutubeShortsPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final muted = context.read<DiscoverProvider>().muted;
    if (muted) {
      _controller.mute();
    } else {
      _controller.unMute();
    }

    if (widget.isActive) {
      _controller.play();
      if (!_viewCounted) {
        _viewCounted = true;
        context.read<DiscoverProvider>().addView(widget.video);
      }
    } else {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox.expand(
          child: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            onReady: () {
              final muted = context.read<DiscoverProvider>().muted;
              if (muted) {
                _controller.mute();
              } else {
                _controller.unMute();
              }
              if (widget.isActive) {
                _controller.play();
              }
            },
          ),
        ),
        VideoBackground(stops: const [0.8, 1.0]),
        Positioned(
          bottom: 50,
          left: 20,
          child: VideoCaption(caption: widget.video.caption),
        ),
      ],
    );
  }
}
