import 'dart:async';
import 'package:flutter/material.dart';
import '../models/quote.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import 'package:go_router/go_router.dart';
import '../theme/colors.dart';
import '../widgets/navigation_bar.dart';  
import 'package:provider/provider.dart';
import '../providers/quote_provider.dart';
import '../utils/export_pdf_stub.dart'
    if (dart.library.html) '../utils/export_pdf_web.dart';
class QuoteScreen extends StatefulWidget {
  static const routeName = '/get-quote';
  const QuoteScreen({super.key});
  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}
class _QuoteScreenState extends State<QuoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final List<Map<String, dynamic>> _items = [
    {
      'productId': '',
      'productName': '',
      'quantity': 1,
      'unitPrice': 0.0,
      'customSpecs': ''
    }
  ];
  double _totalAmount = 0.0;
  bool _isLoading = false;
  Future<void> _exportQuote(String id) async {
    try {
      await exportQuotePdfById(id);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export PDF: $msg')),
      );
      if (msg.contains('Not authenticated') || msg.contains('401')) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) context.go('/login');
      }
    }
  }
  @override
  void dispose() {
    _customerNameController.dispose();
    _customerEmailController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  void _addItem() {
    if (!mounted) return;
    setState(() {
      _items.add({
        'productId': '',
        'productName': '',
        'quantity': 1,
        'unitPrice': 0.0,
        'customSpecs': '',
      });
    });
  }
  void _removeItem(int index) {
    if (_items.length <= 1) return;
    if (!mounted) return;
    setState(() {
      _items.removeAt(index);
      _calculateTotal();
    });
  }
  void _updateItem(int index, String field, dynamic value) {
    if (!mounted) return;
    setState(() {
      _items[index][field] = value;
      if (field == 'productId' || field == 'quantity' || field == 'unitPrice') {
        _calculateTotal();
      }
    });
  }
  void _calculateTotal() {
    double total = 0;
    for (var item in _items) {
      final price = (item['unitPrice'] as num).toDouble();
      final qty = item['quantity'] as int;
      total += price * qty;
    }
    if (!mounted) return;
    setState(() {
      _totalAmount = total;
    });
  }
  Future<List<Product>> _searchProducts(String query) async {
    if (query.isEmpty) return [];
    try {
      final products = await ApiService.getProducts(search: query)
          .timeout(const Duration(seconds: 10));
      if (!mounted) return [];
      return products;
    } catch (_) {
      if (!mounted) return [];
      return [];
    }
  }
  Future<void> _submitQuote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final quoteItems = _items.map((item) {
        return QuoteItem(
          productId: item['productId'] ?? '',
          productName: item['productName'] as String,
          quantity: item['quantity'] as int,
          unitPrice: (item['unitPrice'] as num).toDouble(),
          customSpecs: item['customSpecs'] as String?,
        );
      }).toList();
      final quote = Quote(
        id: '',
        customerName: _customerNameController.text.trim(),
        customerEmail: _customerEmailController.text.trim(),
        company: _companyController.text.trim().isNotEmpty
            ? _companyController.text.trim()
            : null,
        phone: _phoneController.text.trim(),
        items: quoteItems,
        totalAmount: _totalAmount,
        status: 'pending',
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        createdAt: now,
        expiresAt: now.add(const Duration(days: 30)),
      );
      final created = await context.read<QuoteProvider>().createQuote(quote);
      if (!mounted) return;
      FocusScope.of(context).unfocus();
      if (created != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quote request submitted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 300));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to submit quote. Please try again.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit quote: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomNavigationBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Customer Information",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SpaceGrotesk',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _customerNameController,
                            decoration: const InputDecoration(
                              labelText: "Full Name",
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _customerEmailController,
                            decoration: const InputDecoration(
                              labelText: "Email",
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return "Required";
                              if (!v.contains("@")) return "Invalid email";
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _companyController,
                            decoration: const InputDecoration(
                              labelText: "Company (Optional)",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: "Phone",
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "Items",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SpaceGrotesk',
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Autocomplete<Product>(
                                        displayStringForOption: (p) => p.name,
                                        optionsBuilder: (TextEditingValue textEditingValue) async {
                                          if (textEditingValue.text.isEmpty) {
                                            return const Iterable<Product>.empty();
                                          }
                                          final results = await _searchProducts(textEditingValue.text);
                                          if (!mounted) return const Iterable<Product>.empty();
                                          return results;
                                        },
                                        onSelected: (product) {
                                          _updateItem(index, 'productId', product.id);
                                          _updateItem(index, 'productName', product.name);
                                          _updateItem(index, 'unitPrice', product.price);
                                        },
                                        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                          return TextFormField(
                                            controller: controller,
                                            focusNode: focusNode,
                                            decoration: const InputDecoration(
                                              labelText: "Product Name",
                                              border: OutlineInputBorder(),
                                            ),
                                            onChanged: (v) => _updateItem(index, 'productName', v),
                                            validator: (v) => (v == null || v.isEmpty) ? "Required" : null,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 80,
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                          labelText: "Qty",
                                          border: OutlineInputBorder(),
                                        ),
                                        initialValue: item['quantity'].toString(),
                                        keyboardType: TextInputType.number,
                                        onChanged: (v) => _updateItem(
                                            index, 'quantity', int.tryParse(v) ?? 1),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextFormField(
                                        readOnly: true,
                                        controller: TextEditingController(
                                          text: "₱${((item['unitPrice'] as num) * (item['quantity'] as int)).toStringAsFixed(2)}",
                                        ),
                                        decoration: const InputDecoration(
                                          labelText: "Total Price",
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                      onPressed: () => _removeItem(index),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  initialValue: item['customSpecs'],
                                  maxLines: 2,
                                  decoration: const InputDecoration(
                                    labelText: "Custom Specifications (Optional)",
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (v) => _updateItem(index, 'customSpecs', v),
                                ),
                                const SizedBox(height: 12),
                              ],
                            );
                          }).toList(),
                          TextButton.icon(
                            onPressed: _addItem,
                            icon: const Icon(Icons.add),
                            label: const Text("Add Item"),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: "Additional Notes (Optional)",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Total Amount:",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'SpaceGrotesk',
                                    ),
                                  ),
                                  Text(
                                    "₱${_totalAmount.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _submitQuote,
                              child: const Text(
                                "Submit Quote Request",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
