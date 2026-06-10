import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'main_navigation.dart';

class VideoSplashScreen extends StatefulWidget {
  const VideoSplashScreen({super.key});

  @override
  State<VideoSplashScreen> createState() => _VideoSplashScreenState();
}

class _VideoSplashScreenState extends State<VideoSplashScreen> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;
  double _videoOpacity = 1.0;
  bool _hasNavigated = false; // Prevent double navigation

  @override
  void initState() {
    super.initState();
    
    // Safety fallback: if video fails or takes too long, force navigation after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (!_hasNavigated && mounted) {
        _startFadeOutTransition();
      }
    });

    _controller = VideoPlayerController.asset('assets/splash_video.mp4')
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _isVideoInitialized = true;
        });
        _controller.play();
        
        // Navigate after the video completes
        _controller.addListener(_videoListener);
      }).catchError((_) {
        // If video fails to initialize completely, navigate immediately
        if (!_hasNavigated && mounted) {
          _startFadeOutTransition();
        }
      });
  }

  void _videoListener() {
    if (_hasNavigated || !mounted) return;

    // Check if there's a fatal playback error
    if (_controller.value.hasError) {
      _controller.removeListener(_videoListener);
      _startFadeOutTransition();
      return;
    }

    if (_controller.value.isInitialized && 
        _controller.value.position >= _controller.value.duration) {
      _controller.removeListener(_videoListener);
      _startFadeOutTransition();
    }
  }

  void _startFadeOutTransition() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    // 1. Smoothly fade the video to the dark background color
    setState(() {
      _videoOpacity = 0.0;
    });

    // 2. Wait for the fade out to finish, then cross-fade the main app in
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (context, animation, secondaryAnimation) => const MainNavigation(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08080A), // Dark background matching app theme
      body: Center(
        child: _isVideoInitialized
            ? AnimatedOpacity(
                opacity: _videoOpacity,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
            : const SizedBox(), // Show nothing while initializing to prevent flash of loading icon
      ),
    );
  }
}
