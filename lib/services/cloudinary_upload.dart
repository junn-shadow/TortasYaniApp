import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

/// Uploads an image bytes to Cloudinary using a signed request.
///
/// Returns the `secure_url` of the uploaded image, or `null` on failure.
Future<String?> uploadToCloudinary(Uint8List imageBytes, String fileName, String apiKey, String apiSecret, String cloudName) async {
  // Using unsigned preset; no timestamp or signature needed

  final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

  final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';

  final request = http.MultipartRequest('POST', uri)
  ..fields['upload_preset'] = 'tortas_unsigned'
  ..files.add(http.MultipartFile.fromBytes(
    'file',
    imageBytes,
    filename: fileName,
    contentType: MediaType.parse(mimeType),
  ));

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final url = json['secure_url'] as String?;
    print('Cloudinary uploaded URL: $url');
    return url;
  } else {
    print('=== CLOUDINARY UPLOAD FAILED ===');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
  }
  return null;
}
