import 'dart:convert';
import 'package:http/http.dart' as http;


Future<String?> checkForUpdates(String currentTag) async {

  final url = Uri.parse('https://api.github.com/repos/edin45/simple_photogrammetry_gui/releases/latest');

  try {
    final response = await http.get(url, headers: {
      'User-Agent': 'simple_photogrammetry_gui',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final fetchedTag = data['tag_name'] as String?;


      if (fetchedTag != null && fetchedTag != currentTag) {
        return fetchedTag;
      }
    } else {
      print('GitHub API returned status code: ${response.statusCode}');
    }
  } catch (e) {
    
    print('Failed to check for updates: $e');
  }
  
  return null;
}