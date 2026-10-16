import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/config/helpers/human_formats.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';


class VideoButtons extends StatelessWidget {

  final VideoPost video;

  const VideoButtons({
    super.key,
    required this.video
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiscoverProvider>();
    final liked = provider.likedOf(video);

    return Column(
      children: [
        GestureDetector(
          onTap: () => provider.toggleLike(video),
          child: Column(
            children: [
              liked
                  ? Pulse(
                      duration: const Duration(milliseconds: 400),
                      child: const Icon(Icons.favorite, color: Colors.red, size: 30),
                    )
                  : const Icon(Icons.favorite_border, color: Colors.white, size: 30),
              Text(HumanFormats.humanReadbleNumber(provider.likesOf(video).toDouble())),
            ],
          ),
        ),
        const SizedBox( height: 20 ),
        Column(
          children: [
            const Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 30),
            Text(HumanFormats.humanReadbleNumber(provider.viewsOf(video).toDouble())),
          ],
        ),
        const SizedBox( height: 20 ),
        GestureDetector(
          onTap: provider.toggleMuted,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              provider.muted ? Icons.volume_off : Icons.volume_up,
              key: ValueKey(provider.muted),
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ],
    );
  }
}
