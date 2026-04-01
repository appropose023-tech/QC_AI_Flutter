import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://104.154.76.47:8000/compare_live";

  static Future<Map<String, dynamic>> sendImage(File imgFile) async {
    var uri = Uri.parse(baseUrl);
    var request = http.MultipartRequest("POST", uri);

    request.files.add(
      await http.MultipartFile.fromPath("file", imgFile.path),
    );

    var streamed = await request.send();
    var response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(
          jsonDecode(response.body)
      );
    } else {
      throw Exception("Server error: ${response.statusCode}");
    }
  }
}
