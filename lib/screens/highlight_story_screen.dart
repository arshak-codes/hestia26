import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/highlight_item.dart';

class HighlightStoryScreen extends StatefulWidget {
  const HighlightStoryScreen({super.key, required this.highlight});

  final HighlightItem highlight;

  @override
  State<HighlightStoryScreen> createState() => _HighlightStoryScreenState();
}

class _HighlightStoryScreenState extends State<HighlightStoryScreen> {
  VideoPlayerController? _videoController;
  bool _hasVideoError = false;

  @override
  void initState() {
    super.initState();
    if (widget.highlight.isVideo) {
      _videoController =
          VideoPlayerController.networkUrl(Uri.parse(widget.highlight.mediaUrl))
            ..setLooping(true)
            ..setVolume(1)
            ..initialize()
                .then((_) {
                  if (!mounted) {
                    return;
                  }
                  setState(() {});
                  _videoController?.play();
                })
                .catchError((_) {
                  if (!mounted) {
                    return;
                  }
                  setState(() {
                    _hasVideoError = true;
                  });
                });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final highlight = widget.highlight;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child:
                highlight.isVideo
                    ? _buildVideoBody()
                    : Image.network(
                      highlight.mediaUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const _HighlightFallback();
                      },
                    ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 16,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF9070E0),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hestia Highlights',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      highlight.relativeCreatedLabel,
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 60,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (highlight.message.isNotEmpty)
                  Text(
                    highlight.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoBody() {
    if (_hasVideoError) {
      return const _HighlightFallback();
    }

    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE28B9B)),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}

class _HighlightFallback extends StatelessWidget {
  const _HighlightFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF111114),
      child: const Center(
        child: Text(
          'Unable to load highlight',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
