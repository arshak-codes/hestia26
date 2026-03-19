import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize the video player with the local asset
    _controller = VideoPlayerController.asset('assets/logocummming2.mp4')
      ..initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
        });
        _controller.play();
        
        // Listen for when the video ends
        _controller.addListener(() {
          if (_controller.value.position == _controller.value.duration) {
            _navigateToHome();
          }
        });
      }).catchError((error) {
         // Fallback to home if video fails to load
         _navigateToHome();
      });
  }

  void _navigateToHome() {
    // Only navigate if the widget is still mounted
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Typical background for video splash
      body: SizedBox.expand(
        child: _isVideoInitialized
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              )
            // Show a simple loading indicator or black screen until video is ready
            : const SizedBox.shrink(),
      ),
    );
  }
}
