import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/highlight_item.dart';

class HighlightStoryScreen extends StatefulWidget {
  const HighlightStoryScreen({
    super.key,
    required this.highlights,
    required this.initialIndex,
  });

  final List<HighlightItem> highlights;
  final int initialIndex;

  @override
  State<HighlightStoryScreen> createState() => _HighlightStoryScreenState();
}

class _HighlightStoryScreenState extends State<HighlightStoryScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.highlights.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _HighlightStoryPage(highlight: widget.highlights[index]);
            },
          ),
          Positioned(
            top: 24,
            left: 12,
            right: 12,
            child: SafeArea(
              bottom: false,
              child: Row(
                children: List.generate(widget.highlights.length, (index) {
                  final isActive = index == _currentIndex;
                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color:
                            isActive
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          Positioned(
            top: 52,
            left: 16,
            right: 16,
            child: SafeArea(
              bottom: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hestia Highlights',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          widget.highlights[_currentIndex].relativeCreatedLabel,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightStoryPage extends StatefulWidget {
  const _HighlightStoryPage({required this.highlight});

  final HighlightItem highlight;

  @override
  State<_HighlightStoryPage> createState() => _HighlightStoryPageState();
}

class _HighlightStoryPageState extends State<_HighlightStoryPage> {
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
    return Stack(
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
          left: 20,
          right: 20,
          bottom: 32,
          child: SafeArea(
            top: false,
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
        ),
      ],
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
