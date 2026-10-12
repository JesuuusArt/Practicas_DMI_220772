import 'package:flutter/material.dart';

class VideoCaption extends StatefulWidget {

  final String caption;

  const VideoCaption({
    super.key,
    required this.caption,
  });

  @override
  State<VideoCaption> createState() => _VideoCaptionState();
}

class _VideoCaptionState extends State<VideoCaption> {

  bool _isExpanded = false;
  static const int _charLimit = 65;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final caption = widget.caption.trim().isEmpty ? 'Sin descripción' : widget.caption.trim();
    final bool isLong = caption.length > _charLimit;

    final baseStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 15,
          shadows: const [
            Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1)),
          ],
        ) ??
        const TextStyle(color: Colors.white, fontSize: 15);

    final actionStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.9),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    return SizedBox(
      width: size.width * 0.65,
      child: !_isExpanded
          ? GestureDetector(
              onTap: () {
                if (isLong) setState(() => _isExpanded = true);
              },
              child: RichText(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: baseStyle,
                  children: [
                    TextSpan(
                      text: isLong ? '${caption.substring(0, _charLimit)}...' : caption,
                    ),
                    if (isLong)
                      TextSpan(
                        text: ' más',
                        style: actionStyle,
                      ),
                  ],
                ),
              ),
            )
          : Container(
              constraints: BoxConstraints(
                maxHeight: size.height * 0.35,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(10),
              ),
              child: RawScrollbar(
                thumbColor: Colors.white54,
                radius: const Radius.circular(4),
                thickness: 3,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        caption,
                        style: baseStyle,
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => setState(() => _isExpanded = false),
                        child: Text(
                          'menos',
                          style: actionStyle.copyWith(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
