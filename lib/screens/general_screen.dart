import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../models/event.dart';

class GeneralScreen extends StatefulWidget {
  final String categoryName;
  final List<Event> events;

  const GeneralScreen({
    super.key,
    required this.categoryName,
    required this.events,
  });

  @override
  State<GeneralScreen> createState() => _GeneralScreenState();
}

class _GeneralScreenState extends State<GeneralScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.categoryName.toUpperCase()),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.events.length,
              itemBuilder: (context, index) {
                return _buildCarouselItem(index, widget.events[index]);
              },
            ),
          ),
          const SizedBox(height: 120), // Bottom nav padding
        ],
      ),
    );
  }

  Widget _buildCarouselItem(int index, Event event) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 1.0;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page! - index;
          value = (1 - (value.abs() * 0.1)).clamp(0.0, 1.0);
        }
        return Center(
          child: SizedBox(
            height: Curves.easeOut.transform(value) * 600,
            width: Curves.easeOut.transform(value) * 400,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF131316),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE28B9B).withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE28B9B).withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: -5,
            )
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          children: [
            // Image Section
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF2A2E45),
                ),
                child: Image.network(
                  event.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                       color: const Color(0xFF2A2E45),
                       child: const Center(
                         child: Icon(Icons.event, size: 80, color: Colors.white24),
                       ),
                    );
                  },
                ),
              ),
            ),
            // Bottom Info Section
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    event.title.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                  if (event.prizePool.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${event.prizePool.toUpperCase()} PRIZE POOL',
                      style: const TextStyle(
                         color: Color(0xFFE28B9B),
                         fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFE28B9B), Color(0xFF9070E0)],
                        ).createShader(bounds),
                        child: const Text(
                          'REGISTER NOW',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
