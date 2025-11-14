import 'package:flutter/material.dart';
import '../models/product.dart';

class CompareProvider extends ChangeNotifier {
  final List<Product> _products = [];

  List<Product> get products => _products;
  int get count => _products.length;

  void addProduct(Product product) {
    if (!_products.any((p) => p.id == product.id) && _products.length < 4) {
      _products.add(product);
      notifyListeners();
    }
  }

  void removeProduct(String productId) {
    _products.removeWhere((product) => product.id == productId);
    notifyListeners();
  }

  void clear() {
    _products.clear();
    notifyListeners();
  }

  bool isInCompare(Product product) {
    return _products.any((p) => p.id == product.id);
  }

  void toggleProduct(Product product) {
    if (isInCompare(product)) {
      removeProduct(product.id);
    } else if (_products.length < 4) {
      addProduct(product);
    }
  }
}
