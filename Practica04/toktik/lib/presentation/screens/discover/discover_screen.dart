import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DiscoverProvider>();

    if (provider.isLoading && provider.videos.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: provider.videos.length,
        itemBuilder: (context, index) {
          final video = provider.videos[index];

          return Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  video.caption,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${video.likes}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 18),
                    const Icon(Icons.comment, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${video.comments}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}