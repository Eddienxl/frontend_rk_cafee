import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api_constants.dart';

/// Service untuk upload gambar menu ke backend
class ImageUploadService {
  /// Upload bytes dengan filename ke /api/upload
  /// Returns image URL dari backend, atau null jika gagal
  static Future<String?> uploadImageBytes(List<int> bytes, String filename) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/upload');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: filename,
      ));
      
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final json = jsonDecode(responseBody);
        if (json['success'] && json['imageUrl'] != null) {
          return json['imageUrl'] as String;
        }
      }
      return null;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }
}
