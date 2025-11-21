import 'package:flutter/material.dart';
import '../models/quote.dart';
import '../services/api_service.dart';
class QuoteProvider extends ChangeNotifier {
  List<Quote> _quotes = [];
  List<Quote> _filteredQuotes = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedStatus;
  String? _customerEmail;
  List<Quote> get quotes => _filteredQuotes;
  List<Quote> get allQuotes => _quotes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedStatus => _selectedStatus;
  String? get customerEmail => _customerEmail;
  List<String> get statuses => ['pending', 'approved', 'rejected', 'expired'];
  QuoteProvider() {
    loadQuotes();
  }
  Future<void> loadQuotes({
    String? customerEmail,
    String? customerName,
    String? status,
    String? userId,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _quotes = await ApiService.getQuotes(
        customerEmail: customerEmail,
        customerName: customerName,
        status: status,
        userId: userId,
      );
      _customerEmail = customerEmail;
      _selectedStatus = status;
      _filteredQuotes = List.from(_quotes);
      notifyListeners();
    } catch (e) {
      _setError(ApiService.getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }
  Future<void> loadCustomerQuotes({
    String? customerEmail,
    String? customerName,
    String? userId,
  }) async {
    await loadQuotes(
      customerEmail: customerEmail,
      customerName: customerName,
      userId: userId,
    );
  }
  Future<void> loadAdminQuotes({String? status}) async {
    await loadQuotes(status: status);
  }
  void filterByStatus(String? status) {
    _selectedStatus = status;
    if (status == null) {
      _filteredQuotes = List.from(_quotes);
    } else {
      _filteredQuotes = _quotes.where((quote) {
        return quote.status == status;
      }).toList();
    }
    notifyListeners();
  }
  void clearFilters() {
    _selectedStatus = null;
    _filteredQuotes = List.from(_quotes);
    notifyListeners();
  }
  Future<Quote?> getQuote(String id) async {
    try {
      return await ApiService.getQuote(id);
    } catch (e) {
      _setError(ApiService.getErrorMessage(e));
      return null;
    }
  }
  Future<Quote?> createQuote(Quote quote) async {
    _setLoading(true);
    _clearError();
    try {
      final newQuote = await ApiService.createQuote(quote);
      _quotes.insert(0, newQuote);
      _filteredQuotes = List.from(_quotes);
      notifyListeners();
      return newQuote;
    } catch (e) {
      _setError(ApiService.getErrorMessage(e));
      return null;
    } finally {
      _setLoading(false);
    }
  }
  Future<bool> updateQuote(String id, Map<String, dynamic> updates) async {
    _setLoading(true);
    _clearError();
    try {
      final updatedQuote = await ApiService.updateQuote(id, updates);
      final index = _quotes.indexWhere((q) => q.id == id);
      if (index != -1) {
        _quotes[index] = updatedQuote;
        _filteredQuotes = List.from(_quotes);
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
  Future<bool> deleteQuote(String id) async {
    _setLoading(true);
    _clearError();
    try {
      await ApiService.deleteQuote(id);
      _quotes.removeWhere((q) => q.id == id);
      _filteredQuotes = List.from(_quotes);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(ApiService.getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }
  Future<bool> approveQuote(String id) async {
    try {
      final quote = _quotes.firstWhere((q) => q.id == id);
      return await updateQuote(id, {
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
        'status': 'approved',
        'notes': quote.notes,
        if (quote.expiresAt != null) 'expiresAt': quote.expiresAt!.toIso8601String(),
      });
    } catch (e) {
      _setError('Failed to approve quote: $e');
      return false;
    }
  }
  Future<bool> rejectQuote(String id) async {
    try {
      final quote = _quotes.firstWhere((q) => q.id == id);
      return await updateQuote(id, {
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
        'status': 'rejected',
        'notes': quote.notes,
        if (quote.expiresAt != null) 'expiresAt': quote.expiresAt!.toIso8601String(),
      });
    } catch (e) {
      _setError('Failed to reject quote: $e');
      return false;
    }
  }
  int get totalQuotes => _quotes.length;
  int get pendingQuotes => _quotes.where((q) => q.status == 'pending').length;
  int get approvedQuotes => _quotes.where((q) => q.status == 'approved').length;
  int get rejectedQuotes => _quotes.where((q) => q.status == 'rejected').length;
  int get expiredQuotes => _quotes.where((q) => q.isExpired).length;
  double get totalValue {
    return _quotes.fold(0.0, (sum, quote) => sum + quote.totalAmount);
  }
  double get pendingValue {
    return _quotes
        .where((q) => q.status == 'pending')
        .fold(0.0, (sum, quote) => sum + quote.totalAmount);
  }
  double get approvedValue {
    return _quotes
        .where((q) => q.status == 'approved')
        .fold(0.0, (sum, quote) => sum + quote.totalAmount);
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
