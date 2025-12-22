import 'dart:html' as html;
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

/// Service untuk upload image dari web/mobile
/// Menggunakan HTML input element untuk web dan fallback untuk platform lain
class FileUploadService {
  /// Upload image file ke backend dan return image URL
  static Future<String?> uploadImageFile() async {
    try {
      // Create hidden file input element
      final input = html.FileUploadInputElement();
      input.accept = 'image/*';
      input.click();

      // Wait for file selection
      await input.onChange.first;

      if (input.files!.isEmpty) return null;

      final file = input.files!.first;
      final reader = html.FileReader();
      
      // Read file as bytes
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;

      final bytes = reader.result as List<int>;
      
      // Upload to backend
      final uri = Uri.parse('${ApiConstants.baseUrl}/upload');
      final request = http.MultipartRequest('POST', uri);
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: file.name,
      ));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 && responseBody.contains('imageUrl')) {
        // Parse: {"success": true, "imageUrl": "/uploads/menu-..."}
        final startIdx = responseBody.indexOf('"imageUrl"') + 12;
        final endIdx = responseBody.indexOf('"', startIdx);
        final imageUrl = responseBody.substring(startIdx, endIdx);
        return imageUrl;
      }
      
      return null;
    } catch (e) {
      print('File upload error: $e');
      return null;
    }
  }
}
