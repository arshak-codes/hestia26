import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';

class HighlightStoryScreen extends StatefulWidget {
  final String title;
  
  const HighlightStoryScreen({super.key, required this.title});

  @override
  State<HighlightStoryScreen> createState() => _HighlightStoryScreenState();
}

class _HighlightStoryScreenState extends State<HighlightStoryScreen> {
  final storyController = StoryController();

  List<StoryItem> get _storyItems {
    // We are simulating stories related to the clicked highlight.
    // In a real app, these would come from an API based on widget.title
    return [
      StoryItem.pageImage(
        url:
            "https://images.unsplash.com/photo-1540575467063-178a50c2df87?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
        controller: storyController,
        caption: const Text(
          "Great sessions happening now!",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      StoryItem.pageImage(
        url:
            "https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80",
        controller: storyController,
        caption: const Text(
          "Hacking through the night 🚀",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    ];
  }

  @override
  void dispose() {
    storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          StoryView(
            storyItems: _storyItems,
            onStoryShow: (storyItem, index) {
              // print("Showing a story");
            },
            onComplete: () {
              Navigator.pop(context);
            },
            progressPosition: ProgressPosition.top,
            repeat: false,
            controller: storyController,
          ),
          // Custom Header to overlay profile/title like Instagram
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
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'Just now',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Close button
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
        ],
      ),
    );
  }
}
