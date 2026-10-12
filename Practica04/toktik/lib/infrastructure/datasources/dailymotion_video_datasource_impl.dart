import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toktik/domain/datasources/video_posts_datasource.dart';
import 'package:toktik/domain/entities/video_post.dart';

class DailymotionVideoDatasource implements VideoPostDatasource {

  final String search;

  DailymotionVideoDatasource({this.search = 'shorts'});

  @override
  Future<List<VideoPost>> getFavoriteVideosByUser(String userID) async {
    return [];
  }

  @override
  Future<List<VideoPost>> getTrendingVideosByPage(int page) async {
    final url = Uri.parse(
        'https://api.dailymotion.com/videos?fields=id,title,views_total,likes_total&search=$search&limit=10&page=$page');
    final response = await http.get(url);

    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (data['list'] as List<dynamic>?) ?? [];

    return items
        .where((item) => (item['id'] as String?)?.isNotEmpty ?? false)
        .map((item) => VideoPost(
              caption: (item['title'] as String?) ?? 'Dailymotion video',
              dailymotionId: item['id'] as String,
              likes: (item['likes_total'] as int?) ?? 0,
              views: (item['views_total'] as int?) ?? 0,
            ))
        .toList();
  }
}
