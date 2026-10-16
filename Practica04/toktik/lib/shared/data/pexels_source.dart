import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toktik/config/api_keys.dart';
import 'package:toktik/domain/entities/video_post.dart';

Future<List<VideoPost>> fetchPexelsVideos({String query = 'ocean sea'}) async {
  if (ApiKeys.pexels.isEmpty || ApiKeys.pexels.startsWith('PEGA')) return [];

  final url = Uri.parse(
      'https://api.pexels.com/videos/search?query=$query&per_page=10&orientation=portrait');
  final response = await http.get(url, headers: {'Authorization': ApiKeys.pexels});

  if (response.statusCode != 200) return [];

  final data = jsonDecode(response.body) as Map<String, dynamic>;
  final items = (data['videos'] as List<dynamic>?) ?? [];
  final List<VideoPost> result = [];

  for (final item in items) {
    final files = (item['video_files'] as List<dynamic>?) ?? [];
    final mp4s = files.where((f) => f['file_type'] == 'video/mp4').toList();
    if (mp4s.isEmpty) continue;
    final file = mp4s.firstWhere(
      (f) => f['quality'] == 'hd' || f['quality'] == 'sd',
      orElse: () => mp4s.first,
    );
    final link = file['link'] as String?;
    if (link == null) continue;

    result.add(VideoPost(
      caption: (item['user']?['name'] as String?) ?? query,
      videoUrl: link,
      likes: 0,
      views: 0,
    ));
  }

  return result;
}
