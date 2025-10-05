import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/api_service.dart';

class TicketProvider extends ChangeNotifier {
  final List<Ticket> _tickets = [];
  bool _isLoading = false;
  String? _error;

  List<Ticket> get tickets => List.unmodifiable(_tickets);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTickets({String? customerEmail, String? status}) async {
    _setLoading(true);
    _clearError();
    try {
      final result = await ApiService.getTickets(
        customerEmail: customerEmail,
        status: status,
      );
      _tickets
        ..clear()
        ..addAll(result);
      notifyListeners();
    } catch (e) {
      _setError(ApiService.getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<Ticket?> createTicket(Map<String, dynamic> payload) async {
    _setLoading(true);
    _clearError();
    try {
      final created = await ApiService.createTicket(payload);
      _tickets.insert(0, created);
      notifyListeners();
      return created;
    } catch (e) {
      _setError(ApiService.getErrorMessage(e));
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<Ticket?> updateTicket(String id, Map<String, dynamic> updates) async {
    _setLoading(true);
    _clearError();
    try {
      final updated = await ApiService.updateTicket(id, updates);
      final index = _tickets.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tickets[index] = updated;
        notifyListeners();
      }
      return updated;
    } catch (e) {
      _setError(ApiService.getErrorMessage(e));
      return null;
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
  }
}


