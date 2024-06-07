class VideoModel {
  final String text;
  final String videoUrl;

  VideoModel({required this.text, required this.videoUrl});

  Map<String, dynamic> toJson() => {
        'text': text,
        'videoUrl': videoUrl,
      };

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      text: json['text'],
      videoUrl: json['videoUrl'],
    );
  }
}
