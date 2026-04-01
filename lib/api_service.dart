import 'dart:io';
import 'package:http/http.dart' as http;

const String BACKEND_URL = "http://104.154.76.47:8000/compare_live";

class ApiService {
  Future<File?> uploadImage(File imgFile) async {
    try {
      final uri = Uri.parse(BACKEND_URL);
      var request = http.MultipartRequest("POST", uri);
      request.files.add(await http.MultipartFile.fromPath("file", imgFile.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();

        final temp = File("${imgFile.parent.path}/processed.png");
        return temp.writeAsBytes(bytes);
      }
      return null;
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }
}
