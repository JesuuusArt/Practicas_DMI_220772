import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/infrastructure/datasources/dailymotion_video_datasource_impl.dart';
import 'package:toktik/infrastructure/datasources/local_video_datasource_impl.dart';
import 'package:toktik/infrastructure/datasources/pixabay_video_datasource_impl.dart';
import 'package:toktik/infrastructure/datasources/youtube_video_datasource_impl.dart';
import 'package:toktik/infrastructure/repositories/video_posts_repository_impl.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/presentation/providers/theme_provider.dart';
import 'package:toktik/presentation/screens/discover/discover_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final forYouRepository = VideoPostsRepositoryImpl(
      videosDatasource: LocalVideoDatasource()
    );
    final youtubeRepository = VideoPostsRepositoryImpl(
      videosDatasource: YoutubeVideoDatasource()
    );
    final pixabayRepository = VideoPostsRepositoryImpl(
      videosDatasource: PixabayVideoDatasource()
    );
    final dailymotionRepository = VideoPostsRepositoryImpl(
      videosDatasource: DailymotionVideoDatasource()
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => DiscoverProvider(
            forYouRepository: forYouRepository,
            youtubeRepository: youtubeRepository,
            pixabayRepository: pixabayRepository,
            dailymotionRepository: dailymotionRepository,
          )..loadNextPage(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'TokTik',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.theme,
            home: const DiscoverScreen(),
          );
        },
      ),
    );
  }
}
