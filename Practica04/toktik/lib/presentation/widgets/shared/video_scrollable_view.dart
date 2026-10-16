import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/presentation/widgets/shared/video_buttons.dart';
import 'package:toktik/presentation/widgets/video/fullscreen_player.dart';
import 'package:toktik/presentation/widgets/video/youtube_shorts_player.dart';


class VideoScrollableView extends StatefulWidget {

  final List<VideoPost> videos;

  const VideoScrollableView({
    super.key,
    required this.videos
  });

  @override
  State<VideoScrollableView> createState() => _VideoScrollableViewState();
}

class _VideoScrollableViewState extends State<VideoScrollableView> {

  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      itemCount: widget.videos.length,
      onPageChanged: (index) {
        setState(() => _currentPage = index);
      },
      itemBuilder: (context, index) {
        final VideoPost videoPost = widget.videos[index];
        final isActive = index == _currentPage;

        return Stack(
          children: [
            // Video Player + gradiente
            Container(
              color: Colors.black,
              child: Center(
                child: videoPost.isYoutube
                    ? YoutubeShortsPlayer(video: videoPost, isActive: isActive)
                    : FullScreenPlayer(video: videoPost, isActive: isActive),
              ),
            ),

            // Botones
            Positioned(
              bottom: 40,
              right: 20,
              child: VideoButtons(video: videoPost)
            ),

          ],
        );

      },
    );
  }
}
