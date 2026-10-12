import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/presentation/widgets/video/video_background.dart';
import 'package:toktik/presentation/widgets/video/video_caption.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class DailymotionPlayer extends StatefulWidget {

  final VideoPost video;
  final bool isActive;

  const DailymotionPlayer({
    super.key,
    required this.video,
    required this.isActive,
  });

  @override
  State<DailymotionPlayer> createState() => _DailymotionPlayerState();
}

class _DailymotionPlayerState extends State<DailymotionPlayer> {

  late final WebViewController _controller;
  bool _viewCounted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final muted = context.read<DiscoverProvider>().muted;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36')
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      );

    if (_controller.platform is AndroidWebViewController) {
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; background: #000; box-sizing: border-box; overflow: hidden; }
    html, body { width: 100vw; height: 100vh; background: #000; display: flex; align-items: center; justify-content: center; }
    iframe { width: 100%; height: 100%; border: none; }
  </style>
</head>
<body>
  <iframe
    src="https://www.dailymotion.com/embed/video/${widget.video.dailymotionId}?autoplay=${widget.isActive ? 1 : 0}&mute=${muted ? 1 : 0}&controls=0&ui-logo=0&sharing-enable=0"
    allow="autoplay; fullscreen; encrypted-media; picture-in-picture"
    allowfullscreen>
  </iframe>
</body>
</html>
''';

    _controller.loadHtmlString(htmlContent, baseUrl: 'https://www.dailymotion.com');

    if (widget.isActive && !_viewCounted) {
      _viewCounted = true;
      context.read<DiscoverProvider>().addView(widget.video);
    }
  }

  @override
  void didUpdateWidget(covariant DailymotionPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_viewCounted) {
      _viewCounted = true;
      context.read<DiscoverProvider>().addView(widget.video);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox.expand(
          child: WebViewWidget(controller: _controller),
        ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
