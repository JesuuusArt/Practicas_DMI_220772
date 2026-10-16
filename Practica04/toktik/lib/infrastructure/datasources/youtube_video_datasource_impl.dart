import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toktik/config/api_keys.dart';
import 'package:toktik/domain/datasources/video_posts_datasource.dart';
import 'package:toktik/domain/entities/video_post.dart';

class YoutubeVideoDatasource implements VideoPostDatasource {

  @override
  Future<List<VideoPost>> getFavoriteVideosByUser(String userID) async {
    return [];
  }

  @override
  Future<List<VideoPost>> getTrendingVideosByPage(int page) async {
    final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=10&q=shorts&key=${ApiKeys.youtube}');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      return [];
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (data['items'] as List<dynamic>?) ?? [];

    final videos = items
        .where((item) => (item['id'] as Map?)?['videoId'] != null)
        .map((item) => VideoPost(
              caption: item['snippet']?['title'] as String? ?? '',
              youtubeId: item['id']['videoId'] as String,
              likes: 0,
              views: 0,
            ))
        .toList();

    if (videos.isEmpty) return videos;

    final ids = videos.map((v) => v.youtubeId).join(',');
    final detailsUrl = Uri.parse(
        'https://www.googleapis.com/youtube/v3/videos?part=status,statistics&id=$ids&key=${ApiKeys.youtube}');
    final detailsResponse = await http.get(detailsUrl);
    if (detailsResponse.statusCode != 200) return videos;

    final detailsData = jsonDecode(detailsResponse.body) as Map<String, dynamic>;
    final details = (detailsData['items'] as List<dynamic>?) ?? [];
    final embeddableIds = details
        .where((item) => item['status']?['embeddable'] == true)
        .map((item) => item['id'] as String)
        .toSet();

    return videos
        .where((v) => embeddableIds.contains(v.youtubeId))
        .map((v) {
      final detail = details.firstWhere((item) => item['id'] == v.youtubeId,
          orElse: () => null);
      final stats = detail?['statistics'] as Map?;
      return VideoPost(
        caption: v.caption,
        youtubeId: v.youtubeId,
        likes: int.tryParse(stats?['likeCount']?.toString() ?? '') ?? 0,
        views: int.tryParse(stats?['viewCount']?.toString() ?? '') ?? 0,
      );
    }).toList();
  }
}
