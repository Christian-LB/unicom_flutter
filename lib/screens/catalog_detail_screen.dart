import 'package:flutter/material.dart';
import '../widgets/navigation_bar.dart';
import '../services/api_service.dart';
import '../models/product.dart';
class CatalogDetailScreen extends StatefulWidget {
  final String id;
  const CatalogDetailScreen({Key? key, required this.id}) : super(key: key);
  @override
  State<CatalogDetailScreen> createState() => _CatalogDetailScreenState();
}
class _CatalogDetailScreenState extends State<CatalogDetailScreen> {
  Product? product;
  bool loading = true;
  String? error;
  @override
  void initState() {
    super.initState();
    _load();
  }
  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      final p = await ApiService.getProduct(widget.id);
      setState(() { product = p; });
    } catch (e) {
      setState(() { error = e.toString(); });
    } finally {
      setState(() { loading = false; });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomNavigationBar(centered: true),
          Expanded(
            child: loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
                ? Center(child: Text(error!))
                : product == null
                  ? const Center(child: Text('Product not found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product!.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(product!.brand),
                          const SizedBox(height: 16),
                          Text(product!.description),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
