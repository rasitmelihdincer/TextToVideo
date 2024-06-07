import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_to_video/models/video_model.dart';
import 'package:text_to_video/service/runwayml_service.dart';
import '../widgets/loading_widget.dart';
import 'video_player_screen.dart';

class GenerateVideoScreen extends StatefulWidget {
  @override
  _GenerateVideoScreenState createState() => _GenerateVideoScreenState();
}

class _GenerateVideoScreenState extends State<GenerateVideoScreen> {
  final TextEditingController _promptController = TextEditingController();
  String _videoUrl = '';
  String _statusMessage = '';
  Timer? _timer;
  String? _currentUuid;
  double _progress = 0.0;
  bool _loading = false;
  bool _isVertical = true;

  Future<void> generateVideo() async {
    setState(() {
      _loading = true;
      _statusMessage = '';
      _videoUrl = '';
      _progress = 0.0;
    });
    final width = _isVertical ? 768 : 1344;
    final height = _isVertical ? 1344 : 768;

    final result = await RunwayMLService.generateVideo(
        _promptController.text, width, height);

    if (result['success']) {
      _currentUuid = result['uuid'];
      _statusMessage = 'Video oluşturma kuyruğa alındı. UUID: $_currentUuid';
      print(_statusMessage);

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 20), (timer) {
        if (_currentUuid != null) {
          getStatus(_currentUuid!);
        } else {
          timer.cancel();
        }
      });

      setState(() {});
    } else {
      print(
          'Video oluşturma hatası: ${result['statusCode']}, Mesaj: ${result['message']}');
      setState(() {
        _statusMessage =
            'Video oluşturma hatası: ${result['statusCode']}, Mesaj: ${result['message']}';
        _loading = false;
      });
    }
  }

  Future<void> getStatus(String uuid) async {
    final result = await RunwayMLService.getStatus(uuid);

    if (result['success']) {
      if (result['status'] == 'success') {
        _timer?.cancel();
        setState(() {
          _videoUrl = result['url'];
          _statusMessage = 'Video başarıyla oluşturuldu!';
          _progress = 1.0;
          _loading = false;
        });
      } else if (result['status'] == 'failed') {
        _timer?.cancel();
        setState(() {
          _statusMessage = 'Video oluşturma başarısız oldu.';
          _progress = 0.0;
          _loading = false;
        });
      } else {
        setState(() {
          _statusMessage =
              'Video oluşturma durumu: ${result['status']}, İlerleme: ${result['progress']}';
          _progress = result['progress'] ?? 0.0;
        });
      }
    } else {
      print(
          'Durum sorgulama hatası: ${result['statusCode']}, Mesaj: ${result['message']}');
      setState(() {
        _statusMessage =
            'Durum sorgulama hatası: ${result['statusCode']}, Mesaj: ${result['message']}';
        _progress = 0.0;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> saveVideo(String text, String videoUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final savedVideos = prefs.getStringList('saved_videos') ?? [];
    final newVideo = VideoModel(text: text, videoUrl: videoUrl);
    savedVideos.add(jsonEncode(newVideo.toJson()));
    await prefs.setStringList('saved_videos', savedVideos);
    print("object");
    print(text);
    print(savedVideos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff151515),
      appBar: AppBar(
        title: Text(
          'Create Video',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff151515),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _promptController,
              style: TextStyle(
                  color: Colors.white, fontSize: 20), // İçerideki yazının rengi
              decoration: InputDecoration(
                labelText: 'Enter Text',
                labelStyle: TextStyle(color: Colors.white, fontSize: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.white), // Sınır rengi
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide:
                      BorderSide(color: Colors.white), // Etkin sınır rengi
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide:
                      BorderSide(color: Colors.white), // Odaklanmış sınır rengi
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: Colors.white),
                  onPressed: () {
                    _promptController.clear();
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isVertical = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: _isVertical ? Colors.teal : Colors.white,
                    backgroundColor: _isVertical ? Colors.white : Colors.teal,
                  ),
                  child: Text("Vertical"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isVertical = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: !_isVertical ? Colors.teal : Colors.white,
                    backgroundColor: !_isVertical ? Colors.white : Colors.teal,
                  ),
                  child: Text('Horizontal'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: generateVideo,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 115),
              ),
              child: Text(
                'Generate',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            if (_loading) LoadingWidget(progress: _progress),
            SizedBox(height: 16),
            Text(_statusMessage, style: TextStyle(color: Colors.teal)),
            /*
            ElevatedButton(
                onPressed: () {
                  saveVideo("zzzzzzz",
                      "https://files.aigen.video/20240121/377ea72a-1a56-4fbe-b352-43cdcc4e43cd.mp4");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(
                        videoUrl:
                            "https://files.aigen.video/20240121/377ea72a-1a56-4fbe-b352-43cdcc4e43cd.mp4",
                      ),
                    ),
                  );
                },
                child: Text("video player")),
                */
            if (_videoUrl.isNotEmpty)
              Column(
                children: [
                  Text('Oluşturulan Video URL:',
                      style: TextStyle(color: Colors.teal)),
                  InkWell(
                    onTap: () {
                      saveVideo(_promptController.text, _videoUrl);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerScreen(
                            videoUrl: _videoUrl,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      _videoUrl,
                      style: TextStyle(
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
