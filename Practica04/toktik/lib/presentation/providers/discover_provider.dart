import 'package:flutter/foundation.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/shared/data/local_video_post.dart';

class DiscoverProvider extends ChangeNotifier {
  List<VideoPost> videos = [];
  bool _isLoading = false;

  DiscoverProvider() {
    loadNextPage();
  }

  bool get isLoading => _isLoading;

  Future<void> loadNextPage() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    videos = videoPosts.map(VideoPost.fromMap).toList();

    _isLoading = false;
    notifyListeners();
  }
}