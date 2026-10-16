import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toktik/config/api_keys.dart';
import 'package:toktik/domain/datasources/video_posts_datasource.dart';
import 'package:toktik/domain/entities/video_post.dart';

/// DataSource remoto que consume la API de videos de Coverr.
///
/// - Requiere API Key (llega por header `Authorization: Bearer`).
/// - Devuelve archivos `.mp4` directos, por lo que se reproducen con
///   `video_player` (sin WebView ni anuncios).
/// - La API no expone `likes`: se derivan de forma determinista desde el id
///   para que cada video conserve su misma cifra en cada consulta.
class CoverrVideoDatasource implements VideoPostDatasource {

  final String query;

  /// Consultas rotativas: se alterna una por página para variar el contenido.
  static const List<String> _queries = [
    'nature',
    'city',
    'ocean',
    'people',
    'travel',
    'aerial',
    'technology',
  ];

  CoverrVideoDatasource({this.query = ''});

  @override
  Future<List<VideoPost>> getFavoriteVideosByUser(String userID) async {
    return [];
  }

  @override
  Future<List<VideoPost>> getTrendingVideosByPage(int page) async {
    if (!_hasApiKey) return [];

    final currentQuery =
        query.isNotEmpty ? query : _queries[(page - 1) % _queries.length];

    // La API de Coverr pagina desde 0.
    final apiPage = (page - 1).clamp(0, 100);

    final url = Uri.parse(
        'https://api.coverr.co/videos?query=$currentQuery&sort=popular&page=$apiPage&page_size=20&urls=true');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${ApiKeys.coverr}',
    });

    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final hits = (data['hits'] as List<dynamic>?) ?? [];

    final verticals = <VideoPost>[];
    final horizontals = <VideoPost>[];

    for (final hit in hits) {
      final item = hit as Map<String, dynamic>;
      final video = _mapToVideoPost(item);
      if (video == null) continue;

      if (item['is_vertical'] == true) {
        verticals.add(video);
      } else {
        horizontals.add(video);
      }
    }

    // Prioriza los verticales (estilo TikTok) y completa con el resto.
    return [...verticals, ...horizontals].take(10).toList();
  }

  bool get _hasApiKey =>
      ApiKeys.coverr.isNotEmpty && !ApiKeys.coverr.startsWith('PEGA');

  VideoPost? _mapToVideoPost(Map<String, dynamic> item) {
    final urls = item['urls'] as Map<String, dynamic>?;
    final link = (urls?['mp4'] as String?)?.isNotEmpty == true
        ? urls!['mp4'] as String
        : urls?['mp4_preview'] as String?;

    if (link == null || link.isEmpty) return null;

    final id = (item['id'] as String?) ?? link;
    final seed = _seedFrom(id);

    final title = (item['title'] as String?) ?? 'Coverr video';
    final description = (item['description'] as String?) ?? '';
    final tags = (item['tags'] as List<dynamic>?)?.take(4).join(' ') ?? '';

    // Coverr no expone likes: se derivan de forma estable a partir del id.
    final likes = 1200 + (seed % 88000);
    final views = 5000 + (seed % 900000);

    return VideoPost(
      caption: description.isNotEmpty ? '$title — $description $tags' : '$title $tags',
      videoUrl: link,
      likes: likes,
      views: views,
    );
  }

  /// Semilla estable (misma entrada => mismo número) para datos simulados.
  int _seedFrom(String id) {
    var hash = 7;
    for (final code in id.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return hash;
  }
}
