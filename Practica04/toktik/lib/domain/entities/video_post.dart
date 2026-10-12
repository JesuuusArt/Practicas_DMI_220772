class VideoPost {

  final String caption;
  final String? videoUrl;
  final String? youtubeId;
  final String? dailymotionId;
  final int likes;
  final int views;

  VideoPost({
    required this.caption,
    this.videoUrl,
    this.youtubeId,
    this.dailymotionId,
    this.likes = 0,
    this.views = 0
  }) : assert(videoUrl != null || youtubeId != null || dailymotionId != null);

  bool get isYoutube => youtubeId != null;

  bool get isDailymotion => dailymotionId != null;

  bool get isAsset => videoUrl != null && videoUrl!.startsWith('assets/');
}
