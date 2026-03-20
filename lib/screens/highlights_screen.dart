import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:video_player/video_player.dart';

import '../models/highlight_item.dart';
import '../services/highlights_service.dart';
import '../widgets/custom_app_bar.dart';
import 'highlight_story_screen.dart';

class HighlightsScreen extends StatefulWidget {
  const HighlightsScreen({super.key});

  @override
  State<HighlightsScreen> createState() => _HighlightsScreenState();
}

class _HighlightsScreenState extends State<HighlightsScreen> {
  final HighlightsService _highlightsService = HighlightsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'HIGHLIGHTS'),
      body: StreamBuilder<List<HighlightItem>>(
        stream: _highlightsService.streamHighlights(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _HighlightsState(
              title: 'Live feed unavailable',
              subtitle: 'Could not load highlights right now.',
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE28B9B)),
            );
          }

          final highlights = snapshot.data!;
          if (highlights.isEmpty) {
            return const _HighlightsState(
              title: 'No highlights yet',
              subtitle: 'New stories will appear here as soon as they go live.',
            );
          }

          return AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: highlights.length,
              itemBuilder: (context, index) {
                final highlight = highlights[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 450),
                  child: SlideAnimation(
                    verticalOffset: 36,
                    child: FadeInAnimation(
                      child: _buildHighlightCard(context, highlight: highlight),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHighlightCard(
    BuildContext context, {
    required HighlightItem highlight,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => HighlightStoryScreen(highlight: highlight),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white12, width: 1),
          gradient: const LinearGradient(
            colors: [Color(0xFFE28B9B), Color(0xFF9070E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 20,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(1.2),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF131316),
              borderRadius: BorderRadius.circular(22),
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 9 / 14,
                      child:
                          highlight.isVideo
                              ? _HighlightVideoPreview(url: highlight.mediaUrl)
                              : Image.network(
                                highlight.mediaUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const _HighlightMediaFallback();
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
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.18),
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              highlight.isVideo
                                  ? Icons.play_circle_fill_rounded
                                  : Icons.photo_camera_back_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              highlight.isVideo ? 'VIDEO' : 'PHOTO',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            highlight.message.isEmpty
                                ? 'Fresh update from Hestia'
                                : highlight.message,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                highlight.relativeCreatedLabel,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.arrow_outward_rounded,
                                color: Colors.white70,
                                size: 18,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HighlightVideoPreview extends StatefulWidget {
  const _HighlightVideoPreview({required this.url});

  final String url;

  @override
  State<_HighlightVideoPreview> createState() => _HighlightVideoPreviewState();
}

class _HighlightVideoPreviewState extends State<_HighlightVideoPreview> {
  late final VideoPlayerController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.url))
          ..setLooping(true)
          ..setVolume(0)
          ..initialize()
              .then((_) {
                if (!mounted) {
                  return;
                }
                setState(() {});
                _controller.play();
              })
              .catchError((_) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  _hasError = true;
                });
              });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const _HighlightMediaFallback();
    }

    if (!_controller.value.isInitialized) {
      return Container(
        color: const Color(0xFF1B1B1D),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFFE28B9B)),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _controller.value.size.width,
        height: _controller.value.size.height,
        child: VideoPlayer(_controller),
      ),
    );
  }
}

class _HighlightMediaFallback extends StatelessWidget {
  const _HighlightMediaFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1B1B1D),
      child: const Center(
        child: Text(
          'Unable to load media',
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}

class _HighlightsState extends StatelessWidget {
  const _HighlightsState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome_motion_rounded,
              color: Color(0xFFE28B9B),
              size: 42,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
