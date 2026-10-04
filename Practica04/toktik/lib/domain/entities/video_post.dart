class VideoPost {
  final String caption;
  final String videoUrl;
  final int likes;
  final int comments;

  const VideoPost({
    required this.caption,
    required this.videoUrl,
    this.likes = 0,
    this.comments = 0,
  });

  factory VideoPost.fromMap(Map<String, dynamic> map) {
    return VideoPost(
      caption: map['name'] as String? ?? '',
      videoUrl: map['videoUrl'] as String? ?? '',
      likes: map['likes'] as int? ?? 0,
      comments: map['views'] as int? ?? 0,
    );
  }
}