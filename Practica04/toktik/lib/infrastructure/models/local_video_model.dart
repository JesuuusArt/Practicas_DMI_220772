import 'package:toktik/domain/entities/video_post.dart';

class LocalVideoModel {

  final String name;
  final String videoUrl;
  final int likes;
  final int views;

  LocalVideoModel({
    required this.name,
    required this.videoUrl,
    required this.likes,
    required this.views,
  });

  factory LocalVideoModel.fromJson( Map<String, dynamic> json ) {
    return LocalVideoModel(
      name: json['name'] as String? ?? '',
      videoUrl: json['videoUrl'] as String? ?? '',
      likes: json['likes'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
    );
  }

  VideoPost toVideoPostEntity() => VideoPost(
        caption: name,
        videoUrl: videoUrl,
        likes: likes,
        views: views,
      );
}
