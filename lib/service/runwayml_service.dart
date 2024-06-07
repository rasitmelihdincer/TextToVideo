import 'package:http/http.dart' as http;
import 'dart:convert';

class RunwayMLService {
  static const String apiKey =
      '0c8aa780f0msha9502301f9afb97p11d758jsna1dd33195254';
  static const String apiHost = 'runwayml.p.rapidapi.com';

  static Future<Map<String, dynamic>> generateVideo(
      String prompt, int width, int height) async {
    const String url = 'https://runwayml.p.rapidapi.com/generate/text';

    final Map<String, dynamic> payload = {
      'text_prompt': prompt,
      'width': width,
      'height': height,
      'motion': 5,
      'seed': 0,
      'upscale': true,
      'interpolate': true,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'content-type': 'application/json',
        'X-RapidAPI-Key': apiKey,
        'X-RapidAPI-Host': apiHost,
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return {'success': true, 'uuid': json['uuid']};
    } else {
      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': response.body
      };
    }
  }

  static Future<Map<String, dynamic>> getStatus(String uuid) async {
    const String url = 'https://runwayml.p.rapidapi.com/status';

    final response = await http.get(
      Uri.parse('$url?uuid=$uuid'),
      headers: {
        'X-RapidAPI-Key': apiKey,
        'X-RapidAPI-Host': apiHost,
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return {
        'success': true,
        'status': json['status'],
        'progress': json['progress'],
        'url': json['url']
      };
    } else {
      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': response.body
      };
    }
  }
}
