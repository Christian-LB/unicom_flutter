import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/quote.dart';
import '../models/product.dart';
import '../services/api_service.dart';

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
    {'productId': '', 'productName': '', 'quantity': 1, 'unitPrice': 0.0, 'customSpecs': ''}
  ];

  double _totalAmount = 0.0;
  bool _isLoading = false;

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
    setState(() {
      _items.add({'productId': '', 'productName': '', 'quantity': 1, 'unitPrice': 0.0, 'customSpecs': ''});
    });
  }

  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() {
        _items.removeAt(index);
        _calculateTotal();
      });
    }
  }

  void _updateItem(int index, String field, dynamic value) {
    setState(() {
      _items[index][field] = value;
      // If product or quantity changes, update the total
      if (field == 'productId' || field == 'quantity' || field == 'unitPrice') {
        _calculateTotal();
      }
    });
  }

  void _calculateTotal() {
    double total = 0;
    for (var item in _items) {
      final price = (item['unitPrice'] as num).toDouble();
      final quantity = (item['quantity'] as int);
      total += price * quantity;
    }
    setState(() {
      _totalAmount = total;
    });
  }

  Future<List<Product>> _searchProducts(String query) async {
    if (query.isEmpty) return [];
    
    const maxRetries = 3;
    int attempt = 0;
    
    while (attempt < maxRetries) {
      try {
        final products = await ApiService.getProducts(search: query)
            .timeout(const Duration(seconds: 10)); // 10 seconds timeout
        return products;
      } catch (e) {
        attempt++;
        if (attempt == maxRetries) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Failed to load products. Please check your connection.'),
                action: SnackBarAction(
                  label: 'Retry',
                  onPressed: () {
                    _searchProducts(query);
                  },
                ),
              ),
            );
          }
          return [];
        }
        // Wait for 1 second before retrying
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    return [];
  }

  Future<void> _submitQuote() async {
    if (!_formKey.currentState!.validate()) {
      debugPrint('Form validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final quoteData = {
        'customerName': _customerNameController.text.trim(),
        'customerEmail': _customerEmailController.text.trim(),
        if (_companyController.text.trim().isNotEmpty)
          'company': _companyController.text.trim(),
        'phone': _phoneController.text.trim(),
        'items': _items.map((item) => {
          'name': item['productName'] as String,
          'quantity': item['quantity'] as int,
          'price': (item['unitPrice'] as num).toInt(),
          if ((item['customSpecs'] as String?)?.isNotEmpty == true)
            'customSpecs': item['customSpecs'] as String,
        }).toList(),
        'totalAmount': _totalAmount.toInt(),
        'status': 'pending',
        if (_notesController.text.trim().isNotEmpty)
          'notes': _notesController.text.trim(),
        'createdAt': now.toIso8601String(),
        'expiresAt': now.add(const Duration(days: 30)).toIso8601String(),
        // TODO: Replace with actual user ID from auth
        'createdBy': 'current_user_id_here',
      };

      debugPrint('Sending quote to API: $quoteData');
      
      final apiUrl = 'https://unicom-backend.onrender.com/api/quotes';
      debugPrint('Sending request to: $apiUrl');
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Add auth token if required
          // 'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(quoteData),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 201) {
        debugPrint('Quote created successfully');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quote request submitted successfully!'),
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          throw Exception(error['message'] ?? 'Failed to create quote');
        } catch (e) {
          // If we can't parse the error as JSON, show the raw response
          throw Exception('Server responded with status ${response.statusCode}: ${response.body}');
        }
      }
    } catch (e) {
      debugPrint('Error creating quote: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit quote: ${e.toString()}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request a Quote'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Customer Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _customerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _customerEmailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _companyController,
                      decoration: const InputDecoration(
                        labelText: 'Company (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                                  displayStringForOption: (product) => product.name,
                                  optionsBuilder: (TextEditingValue textEditingValue) async {
                                    if (textEditingValue.text.isEmpty) {
                                      return const Iterable<Product>.empty();
                                    }
                                    final products = await _searchProducts(textEditingValue.text);
                                    return products;
                                  },
                                  onSelected: (Product product) {
                                    _updateItem(index, 'productId', product.id);
                                    _updateItem(index, 'productName', product.name);
                                    _updateItem(index, 'unitPrice', product.price);
                                  },
                                  fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                                    // Initialize controller with current product name
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      textEditingController.text = item['productName'];
                                    });
                                    return TextFormField(
                                      controller: textEditingController,
                                      focusNode: focusNode,
                                      decoration: const InputDecoration(
                                        labelText: 'Product Name',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        _updateItem(index, 'productName', value);
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Required';
                                        }
                                        return null;
                                      },
                                    );
                                  },
                                  optionsViewBuilder: (context, onSelected, options) {
                                    return Align(
                                      alignment: Alignment.topLeft,
                                      child: Material(
                                        elevation: 4.0,
                                        child: SizedBox(
                                          height: 200,
                                          child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            itemCount: options.length,
                                            itemBuilder: (context, index) {
                                              final option = options.elementAt(index);
                                              return ListTile(
                                                title: Text(option.name),
                                                subtitle: Text('₱${option.price.toStringAsFixed(2)}'),
                                                onTap: () {
                                                  onSelected(option);
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 80,
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Qty',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  initialValue: item['quantity'].toString(),
                                  onChanged: (value) => _updateItem(
                                      index, 'quantity', int.tryParse(value) ?? 1),
                                  validator: (value) {
                                    if (value == null ||
                                        int.tryParse(value) == null) {
                                      return 'Invalid';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  readOnly: true,
                                  controller: TextEditingController(
                                    text: '₱${((item['unitPrice'] as num) * (item['quantity'] as int)).toStringAsFixed(2)}',
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Total Price',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => _removeItem(index),
                                color: Colors.red,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Custom Specifications (Optional)',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: item['customSpecs'],
                            maxLines: 2,
                            onChanged: (value) =>
                                _updateItem(index, 'customSpecs', value),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }).toList(),
                    TextButton.icon(
                      onPressed: _addItem,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Item'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Additional Notes (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₱${_totalAmount.toStringAsFixed(2)}',
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
                          'Submit Quote Request',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}