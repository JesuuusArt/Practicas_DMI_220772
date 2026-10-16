import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toktik/config/api_keys.dart';
import 'package:toktik/domain/datasources/video_posts_datasource.dart';
import 'package:toktik/domain/entities/video_post.dart';

class PixabayVideoDatasource implements VideoPostDatasource {

  final String query;

  PixabayVideoDatasource({this.query = 'vertical nature'});

  @override
  Future<List<VideoPost>> getFavoriteVideosByUser(String userID) async {
    return [];
  }

  @override
  Future<List<VideoPost>> getTrendingVideosByPage(int page) async {
    if (ApiKeys.pixabay.isEmpty || ApiKeys.pixabay.startsWith('PEGA')) {
      return [];
    }

    final url = Uri.parse(
        'https://pixabay.com/api/videos/?key=${ApiKeys.pixabay}&q=$query&per_page=10&page=$page');
    final response = await http.get(url);

    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (data['hits'] as List<dynamic>?) ?? [];
    final List<VideoPost> result = [];

    for (final item in items) {
      final videos = item['videos'] as Map<String, dynamic>?;
      final video = videos?['tiny'] as Map<String, dynamic>? ??
          videos?['small'] as Map<String, dynamic>? ??
          videos?['medium'] as Map<String, dynamic>?;
      final link = video?['url'] as String?;
      if (link == null) continue;

      final tags = (item['tags'] as String?) ?? query;
      final user = (item['user'] as String?) ?? 'Pixabay';

      result.add(VideoPost(
        caption: '$tags por @$user #pixabay #vertical #video',
        videoUrl: link,
        likes: item['likes'] as int? ?? 0,
        views: item['views'] as int? ?? 0,
      ));
    }

    return result;
  }
}
