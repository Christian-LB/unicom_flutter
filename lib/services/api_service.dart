import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/quote.dart';
import '../models/ticket.dart';
class ApiService {
  // Render backend base URL
  static const String baseUrl = 'https://unicom-backend.onrender.com/api';
  static String? _authToken;
  static void setAuthToken(String? token) {
    _authToken = token;
  }
  static String? get authToken => _authToken;
  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? company,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          if (company != null) 'company': company,
          if (phone != null) 'phone': phone,
        }),
      );
      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  static Future<List<Product>> getProducts({
    String? search,
    String? category,
    List<String>? ids,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) queryParams['q'] = search;
      if (category != null && category.isNotEmpty) queryParams['category'] = category;
      if (ids != null && ids.isNotEmpty) queryParams['ids'] = ids.join(',');
      final uri = Uri.parse('$baseUrl/products').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: _headers,
      ).timeout(
        timeout,
        onTimeout: () {
          throw Exception('Request timed out after ${timeout.inSeconds} seconds');
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data
              .map((json) => Product.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (data is Map<String, dynamic> && data['products'] is List) {
          return (data['products'] as List)
              .map((json) => Product.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Unexpected response format: ${response.body}');
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch products. Status code: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Error parsing response: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
  static Future<Product> getProduct(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$id'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data['product'] is Map<String, dynamic>) {
          return Product.fromJson(data['product'] as Map<String, dynamic>);
        } else if (data is Map<String, dynamic>) {
          return Product.fromJson(data);
        } else {
          throw Exception('Unexpected product response format');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Product not found');
      } else {
        throw Exception('Failed to fetch product');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  static Future<Product> createProduct(Product product) async {
    try {
      final productData = product.toJson();
      productData.remove('id');
      print('DEBUG: createProduct Data: $productData');
      print('DEBUG: createProduct Headers: $_headers');
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: _headers,
        body: jsonEncode(productData),
      );
      print('DEBUG: createProduct Response Status: ${response.statusCode}');
      print('DEBUG: createProduct Response Body: ${response.body}');
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Check if response has a 'product' wrapper or is the product directly
        if (data is Map<String, dynamic>) {
          if (data.containsKey('product')) {
            return Product.fromJson(data['product'] as Map<String, dynamic>);
          } else if (data.containsKey('_id') || data.containsKey('id')) {
            // Response is the product object directly
            return Product.fromJson(data);
          }
        }
        
        throw Exception('Unexpected response format');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? error['message'] ?? 'Failed to create product');
      }
    } catch (e) {
      print('DEBUG: createProduct Exception: $e');
      throw Exception('Network error: $e');
    }
  }
  static Future<Product> updateProduct(String id, Map<String, dynamic> updates) async {
    try {
      print('DEBUG: updateProduct ID: $id');
      print('DEBUG: updateProduct Updates: $updates');
      print('DEBUG: updateProduct Headers: $_headers');
      final response = await http.put(
        Uri.parse('$baseUrl/products/$id'),
        headers: _headers,
        body: jsonEncode(updates),
      );
      print('DEBUG: updateProduct Response Status: ${response.statusCode}');
      print('DEBUG: updateProduct Response Body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 400) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          if (data.containsKey('product')) {
            return Product.fromJson(data['product'] as Map<String, dynamic>);
          } else if (data.containsKey('_id') || data.containsKey('id')) {
            return Product.fromJson(data);
          }
        }
        throw Exception('Unexpected response format');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? error['message'] ?? 'Failed to update product');
      }
    } catch (e) {
      print('DEBUG: updateProduct Exception: $e');
      throw Exception('Network error: $e');
    }
  }
  static Future<void> deleteProduct(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$id'),
        headers: _headers,
      );
      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to delete product');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  static Future<Quote> createQuote(Quote quote) async {
    try {
      final quoteData = {
        'customerName': quote.customerName,
        'customerEmail': quote.customerEmail,
        'company': quote.company,
        'phone': quote.phone,
        'items': quote.items.map((item) => {
          'name': item.productName,
          'price': item.unitPrice,
          'quantity': item.quantity,
          'customSpecs': item.customSpecs,
        }).toList(),
        'totalAmount': quote.totalAmount,
        'status': quote.status,
        'notes': quote.notes,
        'expiresAt': quote.expiresAt?.toIso8601String(),
      };
      final url = Uri.parse('$baseUrl/quotes');
      final body = jsonEncode(quoteData);
      print('Sending request to: $url');
      print('Headers: $_headers');
      print('Request body: $body');
      final response = await http.post(
        url,
        headers: _headers,
        body: body,
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          return Quote.fromJson(data as Map<String, dynamic>);
        } catch (e) {
          throw Exception('Error parsing response: $e');
        }
      } else {
        String errorMessage = 'Failed to create quote. Status: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] ?? errorData['message'] ?? errorMessage;
        } catch (_) {
          errorMessage = '${response.statusCode}: ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create quote: $e');
    }
  }
  static Future<List<Quote>> getQuotes({
    String? customerEmail,
    String? customerName,
    String? status,
    String? userId,
  }) async {
    try {
      final Uri uri;
      if (userId != null && userId.isNotEmpty) {
        uri = Uri.parse('$baseUrl/quotes/my');
      } else {
        final queryParams = <String, String>{};
        if (customerEmail != null && customerEmail.isNotEmpty) {
          queryParams['customerEmail'] = customerEmail;
        }
        if (customerName != null && customerName.isNotEmpty) {
          queryParams['customerName'] = customerName;
        }
        if (status != null && status.isNotEmpty) {
          queryParams['status'] = status;
        }
        uri = Uri.parse('$baseUrl/quotes').replace(queryParameters: queryParams);
      }
      print('DEBUG: getQuotes URI: $uri');
      print('DEBUG: getQuotes Headers: $_headers');
      final response = await http.get(uri, headers: _headers);
      print('DEBUG: getQuotes Response Status: ${response.statusCode}');
      print('DEBUG: getQuotes Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data
              .map((json) => Quote.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (data is Map<String, dynamic> && data['quotes'] is List) {
          return (data['quotes'] as List)
              .map((json) => Quote.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Unexpected quotes response format');
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to fetch quotes');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  static Future<Quote> getQuote(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/quotes/$id'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Quote.fromJson(data['quote'] as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw Exception('Quote not found');
      } else {
        throw Exception('Failed to fetch quote');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  static Future<Quote> updateQuote(String id, Map<String, dynamic> updates) async {
    try {
      final uri = Uri.parse('$baseUrl/quotes/$id');
      print('DEBUG: updateQuote URI: $uri');
      print('DEBUG: updateQuote Updates: $updates');
      print('DEBUG: updateQuote Headers: $_headers');
      final response = await http.put(
        uri,
        headers: _headers,
        body: jsonEncode(updates),
      );
      print('DEBUG: updateQuote Response Status: ${response.statusCode}');
      print('DEBUG: updateQuote Response Body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          if (data.containsKey('quote') && data['quote'] != null) {
            return Quote.fromJson(data['quote'] as Map<String, dynamic>);
          }
          else if (data.containsKey('_id') || data.containsKey('id')) {
            return Quote.fromJson(data);
          }
        }
        throw Exception('Unexpected response format');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? error['message'] ?? 'Failed to update quote');
      }
    } catch (e) {
      print('DEBUG: updateQuote Exception: $e');
      throw Exception('Network error: $e');
    }
  }
  static Future<void> deleteQuote(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/quotes/$id'),
        headers: _headers,
      );
      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to delete quote');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  static Future<Ticket> createTicket(Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tickets'),
        headers: _headers,
        body: jsonEncode(payload),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Ticket.fromJson(data['ticket'] as Map<String, dynamic>);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to create ticket');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  static Future<List<Ticket>> getTickets({
    String? customerEmail,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (customerEmail != null) queryParams['customerEmail'] = customerEmail;
      if (status != null) queryParams['status'] = status;
      final uri = Uri.parse('$baseUrl/tickets').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return data
              .map((json) => Ticket.fromJson(json as Map<String, dynamic>))
              .toList();
        } else if (data is Map<String, dynamic> && data['tickets'] is List) {
          return (data['tickets'] as List)
              .map((json) => Ticket.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Unexpected tickets response format');
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to fetch tickets');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  static Future<Ticket> updateTicket(String id, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tickets/$id'),
        headers: _headers,
        body: jsonEncode(updates),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Ticket.fromJson(data['ticket'] as Map<String, dynamic>);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to update ticket');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  static String getErrorMessage(dynamic error) {
    if (error is String) return error;
    if (error is Exception) return error.toString();
    return 'An unknown error occurred';
  }
}
