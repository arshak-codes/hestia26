import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../models/highlight_item.dart';
import '../widgets/hestia_loader.dart';

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

class _HighlightStoryScreenState extends State<HighlightStoryScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _photoDisplayDuration = Duration(seconds: 15);
  static const Duration _pageTransitionDuration = Duration(milliseconds: 420);

  late final PageController _pageController;
  late final AnimationController _progressController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _progressController = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _handleStoryFinished(_currentIndex);
        }
      });
    _startCurrentHighlight();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _startCurrentHighlight() {
    _progressController
      ..stop()
      ..reset();

    final currentHighlight = widget.highlights[_currentIndex];
    if (!currentHighlight.isVideo) {
      _progressController.duration = _photoDisplayDuration;
      _progressController.forward();
    }
  }

  void _handlePageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _startCurrentHighlight();
  }

  void _handleStoryFinished(int index) {
    if (!mounted || index != _currentIndex) {
      return;
    }

    _showNextHighlight();
  }

  void _handleVideoReady(int index, Duration duration) {
    if (!mounted || index != _currentIndex || duration <= Duration.zero) {
      return;
    }

    _progressController
      ..stop()
      ..reset()
      ..duration = duration
      ..forward();
  }

  void _handleVideoCompleted(int index) {
    _handleStoryFinished(index);
  }

  void _showPreviousHighlight() {
    if (_currentIndex <= 0) {
      _startCurrentHighlight();
      return;
    }

    _pageController.previousPage(
      duration: _pageTransitionDuration,
      curve: Curves.easeInOutCubic,
    );
  }

  void _showNextHighlight() {
    if (_currentIndex >= widget.highlights.length - 1) {
      Navigator.of(context).maybePop();
      return;
    }

    _pageController.nextPage(
      duration: _pageTransitionDuration,
      curve: Curves.easeInOutCubic,
    );
  }

  void _handleTapNavigation(TapUpDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tapX = details.globalPosition.dx;

    if (tapX < screenWidth / 2) {
      _showPreviousHighlight();
    } else {
      _showNextHighlight();
    }
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
            onPageChanged: _handlePageChanged,
            itemBuilder: (context, index) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _HighlightStoryPage(
                  key: ValueKey(widget.highlights[index].id),
                  highlight: widget.highlights[index],
                  isActive: index == _currentIndex,
                  onVideoReady:
                      (duration) => _handleVideoReady(index, duration),
                  onVideoCompleted: () => _handleVideoCompleted(index),
                ),
              );
            },
          ),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: _handleTapNavigation,
            ),
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
                  final isCompleted = index < _currentIndex;
                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, _) {
                            final widthFactor =
                                isCompleted
                                    ? 1.0
                                    : isActive
                                    ? _progressController.value
                                    : 0.0;
                            return FractionallySizedBox(
                              widthFactor: widthFactor.clamp(0.0, 1.0),
                              child: Container(color: Colors.white),
                            );
                          },
                        ),
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
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Image.asset(
                      'assets/hestia-logo-final-1.png',
                      fit: BoxFit.cover,
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
  const _HighlightStoryPage({
    super.key,
    required this.highlight,
    required this.isActive,
    required this.onVideoReady,
    required this.onVideoCompleted,
  });

  final HighlightItem highlight;
  final bool isActive;
  final ValueChanged<Duration> onVideoReady;
  final VoidCallback onVideoCompleted;

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
            ..setLooping(false)
            ..setVolume(1)
            ..initialize()
                .then((_) {
                  if (!mounted) {
                    return;
                  }
                  _videoController?.addListener(_handleVideoStateChanged);
                  setState(() {});
                  widget.onVideoReady(_videoController!.value.duration);
                  if (widget.isActive) {
                    _videoController?.play();
                  }
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
    _videoController?.removeListener(_handleVideoStateChanged);
    _videoController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _HighlightStoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.highlight.isVideo) {
      return;
    }

    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (widget.isActive && !oldWidget.isActive) {
      controller
        ..seekTo(Duration.zero)
        ..play();
      widget.onVideoReady(controller.value.duration);
    } else if (!widget.isActive && oldWidget.isActive) {
      controller.pause();
    }
  }

  void _handleVideoStateChanged() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized || !widget.isActive) {
      return;
    }

    final position = controller.value.position;
    final duration = controller.value.duration;
    if (duration > Duration.zero && position >= duration) {
      widget.onVideoCompleted();
    }
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
        child: HestiaLoader(size: 52, label: 'Loading story'),
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
