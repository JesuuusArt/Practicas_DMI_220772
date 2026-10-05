import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/infrastructure/models/local_video_model.dart';

import 'package:toktik/shared/data/local_video_post.dart';



class DiscoverProvider extends ChangeNotifier {

  // TODO: Repository, DataSource

  bool initialLoading = true;
  List<VideoPost> videos = [];

  DiscoverProvider();

  Future<void> loadNextPage() async {

    // await Future.delayed( const Duration(seconds: 2) );

    final List<VideoPost> newVideos = videoPosts
        .where( ( video ) => ( video['views'] as int? ?? 0 ) >= ( video['likes'] as int? ?? 0 ) )
        .map( ( video ) => LocalVideoModel.fromJson(video).toVideoPostEntity() )
        .toList();

    videos.addAll( newVideos );
    initialLoading = false;
    notifyListeners();
  }


}
