import 'dart:async';
import 'dart:html' as html;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

Future<void> exportQuotePdfById(String id) async {
  final uri = Uri.parse('${ApiService.baseUrl}/quotes/export/$id');
  final headers = <String, String>{
    'Accept': 'application/pdf',
  };

  var token = ApiService.authToken;
  var hasToken = token != null && token.isNotEmpty;

  // If the in-memory token is missing, try to recover from SharedPreferences (web -> localStorage)
  if (!hasToken) {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('auth_token');
      if (cached != null && cached.isNotEmpty) {
        ApiService.setAuthToken(cached);
        token = cached;
        hasToken = true;
      }
    } catch (_) {
      // ignore: avoid_print
      print('[exportQuotePdfById] Failed to read cached token');
    }
  }

  // Simple console hint to aid debugging without exposing the token
  // ignore: avoid_print
  print('[exportQuotePdfById] tokenPresent=$hasToken id=$id');

  if (!hasToken) {
    throw Exception('Not authenticated. Please sign in to export the PDF.');
  }

  headers['Authorization'] = 'Bearer $token';

  final res = await http.get(uri, headers: headers);
  if (res.statusCode >= 200 && res.statusCode < 300) {
    final blob = html.Blob([res.bodyBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..target = '_blank'
      ..download = 'quote-$id.pdf';
    anchor.click();
    // Keep the object URL alive for a short while so DevTools/new tab can access it
    Timer(const Duration(seconds: 60), () => html.Url.revokeObjectUrl(url));
  } else {
    final body = res.body;
    throw Exception('Export failed (${res.statusCode}): ${body.isNotEmpty ? body : 'Unauthorized or invalid token'}');
  }
}
