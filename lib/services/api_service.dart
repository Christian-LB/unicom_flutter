import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/product.dart';
import '../models/quote.dart';
import '../models/ticket.dart';

class ApiService {
  // Replace with your actual Vercel deployment URL
  static const String baseUrl = 'https://unicom-catalog-7ekonxxuy-justpres-projects.vercel.app/api';
  
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // Auth endpoints
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

  // Product endpoints
  static Future<List<Product>> getProducts({
    String? search,
    String? category,
    List<String>? ids,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) queryParams['q'] = search;
      if (category != null && category.isNotEmpty) queryParams['category'] = category;
      if (ids != null && ids.isNotEmpty) queryParams['ids'] = ids.join(',');

      final uri = Uri.parse('$baseUrl/products').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['products'] as List)
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch products');
      }
    } catch (e) {
      throw Exception('Network error: $e');
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
        return Product.fromJson(data['product'] as Map<String, dynamic>);
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
      final response = await http.post(
        Uri.parse('$baseUrl/products'),
        headers: _headers,
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Product.fromJson(data['product'] as Map<String, dynamic>);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to create product');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Product> updateProduct(String id, Map<String, dynamic> updates) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/$id'),
        headers: _headers,
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Product.fromJson(data['product'] as Map<String, dynamic>);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to update product');
      }
    } catch (e) {
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

  // Quote endpoints
  static Future<Quote> createQuote(Quote quote) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/quotes'),
        headers: _headers,
        body: jsonEncode(quote.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Quote.fromJson(data['quote'] as Map<String, dynamic>);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to create quote');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<List<Quote>> getQuotes({
    String? customerEmail,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (customerEmail != null && customerEmail.isNotEmpty) {
        queryParams['customerEmail'] = customerEmail;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse('$baseUrl/quotes').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['quotes'] as List)
            .map((json) => Quote.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch quotes');
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
      final response = await http.patch(
        Uri.parse('$baseUrl/quotes/$id'),
        headers: _headers,
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Quote.fromJson(data['quote'] as Map<String, dynamic>);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to update quote');
      }
    } catch (e) {
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

  // Ticket endpoints
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
      if (customerEmail != null && customerEmail.isNotEmpty) {
        queryParams['customerEmail'] = customerEmail;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse('$baseUrl/tickets').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['tickets'] as List)
            .map((json) => Ticket.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch tickets');
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

  // Utility methods
  static String getErrorMessage(dynamic error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }
}
