import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/domain/repositories/video_posts_repository.dart';

class _VideoStats {
  int likes;
  int views;
  bool liked;
  _VideoStats({required this.likes, required this.views, required this.liked});
}

class DiscoverProvider extends ChangeNotifier {

  final VideoPostRepository forYouRepository;
  final VideoPostRepository? youtubeRepository;
  final VideoPostRepository? pixabayRepository;
  final VideoPostRepository? vimeoRepository;

  bool initialLoading = true;
  List<VideoPost> forYouVideos = [];
  List<VideoPost> youtubeVideos = [];
  List<VideoPost> pixabayVideos = [];
  List<VideoPost> vimeoVideos = [];
  List<VideoPost> discoverVideos = [];

  List<VideoPost> get localVideos => forYouVideos;

  int currentIndex = 0;
  bool muted = false;

  final Map<String, _VideoStats> _stats = {};
  SharedPreferences? _prefs;

  DiscoverProvider({
    required this.forYouRepository,
    this.youtubeRepository,
    this.pixabayRepository,
    this.vimeoRepository,
  });

  String _keyOf(VideoPost v) => v.youtubeId ?? v.vimeoId ?? v.videoUrl ?? '';

  List<VideoPost> get favoriteVideos {
    final all = [...forYouVideos, ...discoverVideos];
    final seen = <String>{};
    final favs = <VideoPost>[];
    for (final v in all) {
      final k = _keyOf(v);
      if (k.isNotEmpty && !seen.contains(k) && likedOf(v)) {
        seen.add(k);
        favs.add(v);
      }
    }
    return favs;
  }

  Future<void> loadNextPage() async {
    _prefs = await SharedPreferences.getInstance();
    muted = _prefs!.getBool('muted') ?? false;

    final results = await Future.wait([
      forYouRepository.getTrendingVideosByPage(1).catchError((_) => <VideoPost>[]),
      youtubeRepository?.getTrendingVideosByPage(1).catchError((_) => <VideoPost>[]) ?? Future.value(<VideoPost>[]),
      pixabayRepository?.getTrendingVideosByPage(1).catchError((_) => <VideoPost>[]) ?? Future.value(<VideoPost>[]),
      vimeoRepository?.getTrendingVideosByPage(1).catchError((_) => <VideoPost>[]) ?? Future.value(<VideoPost>[]),
    ]);

    forYouVideos = results[0];
    youtubeVideos = results[1];
    pixabayVideos = results[2];
    vimeoVideos = results[3];

    // Discover integra las 3 APIs remotas (YouTube, Pixabay, Vimeo)
    discoverVideos = [...youtubeVideos, ...pixabayVideos, ...vimeoVideos];

    final allVideos = [...forYouVideos, ...discoverVideos];

    for (final v in allVideos) {
      final k = _keyOf(v);
      _stats[k] = _VideoStats(
        likes: _prefs!.getInt('likes_$k') ?? v.likes,
        views: _prefs!.getInt('views_$k') ?? v.views,
        liked: _prefs!.getBool('liked_$k') ?? false,
      );
    }

    initialLoading = false;
    notifyListeners();
  }

  int likesOf(VideoPost v) => _stats[_keyOf(v)]?.likes ?? v.likes;
  int viewsOf(VideoPost v) => _stats[_keyOf(v)]?.views ?? v.views;
  bool likedOf(VideoPost v) => _stats[_keyOf(v)]?.liked ?? false;

  Future<void> addView(VideoPost v) async {
    final s = _stats[_keyOf(v)];
    if (s == null) return;
    s.views++;
    await _prefs?.setInt('views_${_keyOf(v)}', s.views);
    notifyListeners();
  }

  Future<void> toggleLike(VideoPost v) async {
    final s = _stats[_keyOf(v)];
    if (s == null) return;
    s.liked = !s.liked;
    s.likes = (s.likes + (s.liked ? 1 : -1)).clamp(0, 1 << 30);
    await _prefs?.setInt('likes_${_keyOf(v)}', s.likes);
    await _prefs?.setBool('liked_${_keyOf(v)}', s.liked);
    notifyListeners();
  }

  Future<void> toggleMuted() async {
    muted = !muted;
    await _prefs?.setBool('muted', muted);
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    if (currentIndex == index) return;
    currentIndex = index;
    notifyListeners();
  }
}
