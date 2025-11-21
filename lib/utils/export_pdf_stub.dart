import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
Future<void> exportQuotePdfById(String id) async {
  final url = '${ApiService.baseUrl}/quotes/export/$id';
  try {
    final headers = {
      'Content-Type': 'application/json',
    };
    final token = ApiService.authToken;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/quote_$id.pdf');
      await file.writeAsBytes(bytes, flush: true);
      final uri = Uri.file(file.path);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw Exception('Could not launch PDF viewer for ${file.path}');
      }
    } else {
      throw Exception('Failed to download PDF: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error exporting PDF: $e');
  }
}
