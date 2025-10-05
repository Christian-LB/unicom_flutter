import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedCategory;

  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  List<String> get categories {
    final categories = _products.map((p) => p.category).toSet().toList();
    categories.sort();
    return categories;
  }

  ProductProvider() {
    loadProducts();
  }

  Future<void> loadProducts({String? search, String? category}) async {
    _setLoading(true);
    _clearError();

    try {
      _products = await ApiService.getProducts(
        search: search,
        category: category,
      );
      _searchQuery = search ?? '';
      _selectedCategory = category;
      _filteredProducts = List.from(_products);
      notifyListeners();
    } catch (e) {
      _setError(ApiService.getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchProducts(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = _products.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase()) ||
               product.description.toLowerCase().contains(query.toLowerCase()) ||
               product.brand.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  void filterByCategory(String? category) {
    _selectedCategory = category;
    if (category == null) {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = _products.where((product) {
        return product.category == category;
      }).toList();
    }
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _filteredProducts = List.from(_products);
    notifyListeners();
  }

  Future<Product?> getProduct(String id) async {
    try {
      return await ApiService.getProduct(id);
    } catch (e) {
      _setError(ApiService.getErrorMessage(e));
      return null;
    }
  }

  Future<bool> createProduct(Product product) async {
    _setLoading(true);
    _clearError();

    try {
      final newProduct = await ApiService.createProduct(product);
      _products.insert(0, newProduct);
      _filteredProducts = List.from(_products);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(ApiService.getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProduct(String id, Map<String, dynamic> updates) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedProduct = await ApiService.updateProduct(id, updates);
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updatedProduct;
        _filteredProducts = List.from(_products);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError(ApiService.getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteProduct(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await ApiService.deleteProduct(id);
      _products.removeWhere((p) => p.id == id);
      _filteredProducts = List.from(_products);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(ApiService.getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
