import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:text_to_video/screens/generate_video_screen.dart';
import 'package:text_to_video/screens/main_screen.dart';
import 'package:video_player/video_player.dart';

class IntroWidget extends StatefulWidget {
  const IntroWidget({
    super.key,
    required this.color,
    required this.title,
    required this.description,
    required this.skip,
    required this.videoPath,
    required this.onTab,
    required this.index,
  });

  final String color;
  final String title;
  final String description;
  final bool skip;
  final String videoPath;
  final VoidCallback onTab;
  final int index;

  @override
  _IntroWidgetState createState() => _IntroWidgetState();
}

class _IntroWidgetState extends State<IntroWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToGenerateVideoScreen(BuildContext context) {
    _controller.pause();
    _controller.dispose();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: _controller.value.isInitialized
              ? VideoPlayer(_controller)
              : Center(child: CircularProgressIndicator()),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.5),
                ],
                stops: [0.0, 0.2, 0.8, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 30),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.description,
                  style: const TextStyle(
                    fontSize: 24,
                    height: 1.5,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 54,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: MaterialButton(
                    color: hexToColor(widget.color),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onPressed: () => _navigateToGenerateVideoScreen(context),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Color hexToColor(String hex) {
  assert(RegExp(r'^#([0-9a-fA-F]{6})|([0-9a-fA-F]{8})$').hasMatch(hex));

  return Color(int.parse(hex.substring(1), radix: 16) +
      (hex.length == 7 ? 0xFF000000 : 0x00000000));
}
