import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/presentation/widgets/video/video_background.dart';
import 'package:toktik/presentation/widgets/video/video_caption.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

/// Reproductor embebido de Vimeo.
///
/// A diferencia de otros embeds, aqui se usa la **Player.js API** de Vimeo:
/// al terminar de cargar la pagina se expone `setMuted` / `setPlaying`, y la
/// app los invoca por JavaScript. Asi el boton de silencio funciona **en vivo**
/// (sin recargar el video) y el video se pausa al salir de la pantalla.
class VimeoPlayer extends StatefulWidget {

  final VideoPost video;
  final bool isActive;

  const VimeoPlayer({
    super.key,
    required this.video,
    required this.isActive,
  });

  @override
  State<VimeoPlayer> createState() => _VimeoPlayerState();
}

class _VimeoPlayerState extends State<VimeoPlayer> {

  late final WebViewController _controller;
  late final DiscoverProvider _provider;

  bool _viewCounted = false;
  bool _isLoading = true;
  late bool _lastMuted;

  @override
  void initState() {
    super.initState();

    _provider = context.read<DiscoverProvider>();
    _lastMuted = _provider.muted;
    _provider.addListener(_syncPlayerState);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36')
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
            _syncPlayerState();
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
    html, body { width: 100vw; height: 100vh; background: #000; }
    #player { position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: none; }
  </style>
</head>
<body>
  <iframe id="player"
    src="https://player.vimeo.com/video/${widget.video.vimeoId}?autoplay=${widget.isActive ? 1 : 0}&muted=${_lastMuted ? 1 : 0}&loop=1&title=0&byline=0&portrait=0&dnt=1"
    allow="autoplay; fullscreen; encrypted-media; picture-in-picture"
    allowfullscreen>
  </iframe>
  <script src="https://player.vimeo.com/api/player.js"></script>
  <script>
    var player = new Vimeo.Player(document.getElementById('player'));
    function setMuted(m) { player.setMuted(m); }
    function setPlaying(p) { if (p) { player.play(); } else { player.pause(); } }
  </script>
</body>
</html>
''';

    _controller.loadHtmlString(htmlContent, baseUrl: 'https://player.vimeo.com');

    if (widget.isActive && !_viewCounted) {
      _viewCounted = true;
      _provider.addView(widget.video);
    }
  }

  @override
  void dispose() {
    _provider.removeListener(_syncPlayerState);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant VimeoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive != oldWidget.isActive) {
      _runJs('setPlaying($widget.isActive)');
      if (widget.isActive && !_viewCounted) {
        _viewCounted = true;
        _provider.addView(widget.video);
      }
    }

    _syncPlayerState();
  }

  /// Mantiene el video sincronizado con el estado global (mute / activo).
  void _syncPlayerState() {
    if (!mounted) return;
    if (_provider.muted != _lastMuted) {
      _lastMuted = _provider.muted;
      _runJs('setMuted($_lastMuted)');
    }
  }

  Future<void> _runJs(String code) async {
    try {
      await _controller.runJavaScript(code);
    } catch (_) {
      // La pagina aun no esta lista: el estado se sincroniza en onPageFinished.
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
