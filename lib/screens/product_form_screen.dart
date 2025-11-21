import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/navigation_bar.dart';
import '../providers/product_provider.dart';
import '../theme/colors.dart';
import '../models/product.dart';
class ProductFormScreen extends StatefulWidget {
  final String? productId;
  const ProductFormScreen({Key? key, this.productId}) : super(key: key);
  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}
class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _specsController = TextEditingController();
  bool _isLoading = false;
  bool _isEditMode = false;
  bool _inStock = true;
  Product? _existingProduct;
  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _isEditMode = true;
      _loadProduct();
    }
  }
  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);
    try {
      final product = await context.read<ProductProvider>().getProduct(widget.productId!);
      if (product != null && mounted) {
        setState(() {
          _existingProduct = product;
          _nameController.text = product.name;
          _descriptionController.text = product.description;
          _categoryController.text = product.category;
          _brandController.text = product.brand;
          _priceController.text = product.price.toString();
          _imageUrlController.text = product.image ?? '';
          _inStock = product.inStock;
          _specsController.text = product.specifications.entries
              .map((e) => '${e.key}: ${e.value}')
              .join('\n');
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading product: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _specsController.dispose();
    super.dispose();
  }
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final specsMap = <String, String>{};
      final lines = _specsController.text.split('\n');
      for (var line in lines) {
        if (line.trim().isEmpty) continue;
        final parts = line.split(':');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final value = parts.sublist(1).join(':').trim();
          specsMap[key] = value;
        }
      }
      if (_isEditMode && _existingProduct != null) {
        final updates = {
          'name': _nameController.text,
          'description': _descriptionController.text,
          'category': _categoryController.text,
          'brand': _brandController.text,
          'price': double.parse(_priceController.text),
          'stock': _inStock ? 1 : 0, 
          'image': _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
          'specifications': specsMap,
        };
        final success = await context.read<ProductProvider>().updateProduct(
          widget.productId!,
          updates,
        );
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          context.go('/admin/products');
        } else if (mounted) {
          final errorMsg = context.read<ProductProvider>().error ?? 'Failed to update product';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        final product = Product(
          id: '', 
          name: _nameController.text,
          description: _descriptionController.text.isEmpty ? 'No description' : _descriptionController.text,
          category: _categoryController.text,
          brand: _brandController.text.isEmpty ? 'Unknown' : _brandController.text,
          price: double.parse(_priceController.text),
          inStock: _inStock,
          image: _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
          specifications: specsMap,
          createdAt: DateTime.now(),
        );
        final success = await context.read<ProductProvider>().createProduct(product);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product created successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          context.go('/admin/products');
        } else if (mounted) {
          final errorMsg = context.read<ProductProvider>().error ?? 'Failed to create product';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving product: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomNavigationBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: _isLoading && _isEditMode
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(48),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.arrow_back),
                                        onPressed: () => context.go('/admin/products'),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _isEditMode ? 'Edit Product' : 'Create Product',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.foreground,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Product Name *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.inventory_2),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Product name is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _descriptionController,
                                    decoration: const InputDecoration(
                                      labelText: 'Description',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.description),
                                    ),
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _categoryController,
                                    decoration: const InputDecoration(
                                      labelText: 'Category *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.category),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Category is required';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _brandController,
                                    decoration: const InputDecoration(
                                      labelText: 'Brand',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.business),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _imageUrlController,
                                    decoration: const InputDecoration(
                                      labelText: 'Image URL',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.image),
                                      hintText: 'https://example.com/image.jpg',
                                    ),
                                    keyboardType: TextInputType.url,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _priceController,
                                    decoration: const InputDecoration(
                                      labelText: 'Price *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.attach_money),
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Price is required';
                                      }
                                      if (double.tryParse(value) == null) {
                                        return 'Invalid price';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  CheckboxListTile(
                                    title: const Text('In Stock'),
                                    value: _inStock,
                                    onChanged: (value) {
                                      setState(() {
                                        _inStock = value ?? true;
                                      });
                                    },
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _specsController,
                                    decoration: const InputDecoration(
                                      labelText: 'Specifications (key: value format)',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.list),
                                      helperText: 'Enter each specification as "key: value" on a new line',
                                    ),
                                    maxLines: 5,
                                  ),
                                  const SizedBox(height: 32),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton(
                                        onPressed: _isLoading
                                            ? null
                                            : () => context.go('/admin/products'),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 16,
                                          ),
                                        ),
                                        child: const Text('Cancel'),
                                      ),
                                      const SizedBox(width: 16),
                                      ElevatedButton(
                                        onPressed: _isLoading ? null : _saveProduct,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 16,
                                          ),
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Text(_isEditMode ? 'Update Product' : 'Create Product'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
