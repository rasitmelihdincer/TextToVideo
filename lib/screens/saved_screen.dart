import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_to_video/models/video_model.dart';
import 'package:text_to_video/screens/video_player_screen.dart';

class SavedVideosScreen extends StatefulWidget {
  @override
  _SavedVideosScreenState createState() => _SavedVideosScreenState();
}

class _SavedVideosScreenState extends State<SavedVideosScreen> {
  List<VideoModel> _savedVideos = [];

  @override
  void initState() {
    super.initState();
    _loadSavedVideos();
  }

  Future<void> _loadSavedVideos() async {
    final prefs = await SharedPreferences.getInstance();
    final savedVideos = prefs.getStringList('saved_videos') ?? [];
    setState(() {
      _savedVideos = savedVideos
          .map((video) => VideoModel.fromJson(jsonDecode(video)))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff151515),
      appBar: AppBar(
        title: Text(
          'History',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff151515),
      ),
      body: _savedVideos.isEmpty
          ? Center(
              child: Text(
                'No saved videos.',
                style: TextStyle(color: Colors.white),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  childAspectRatio: 1.0,
                ),
                itemCount: _savedVideos.length,
                itemBuilder: (context, index) {
                  final video = _savedVideos[index];
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerScreen(
                            videoUrl: video.videoUrl,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    child: Text(
                      video.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
