import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/navigation_bar.dart';
import '../providers/compare_provider.dart';
import '../models/product.dart';
import '../theme/colors.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CustomNavigationBar(centered: true),

            /// 👇 Expanded prevents overall layout overflow
            Expanded(
              child: Consumer<CompareProvider>(
                builder: (context, compareProvider, _) {
                  final products = compareProvider.products;

                  if (products.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          'No products to compare.\nAdd products from the catalog to compare them.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ),
                    );
                  }

                  // Collect all unique specification keys across all products
                  final allSpecs = <String>{};
                  for (final product in products) {
                    allSpecs.addAll(product.specifications.keys);
                  }
                  final sortedSpecs = allSpecs.toList()..sort();

                  return Column(
                    children: [
                      // Header with clear button
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Compare Products (${products.length}/4)',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (products.isNotEmpty)
                              TextButton.icon(
                                onPressed: () => compareProvider.clear(),
                                icon: const Icon(Icons.delete_outline, size: 20),
                                label: const Text('Clear All'),
                              ),
                          ],
                        ),
                      ),

                      /// 👇 The fix: Wrap table + button inside scrollable Expanded view
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 32),
                          child: Column(
                            children: [
                              // Horizontal scroll for table
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(minWidth: 400),
                                  child: DataTable(
                                    columnSpacing: 24,
                                    dataRowMinHeight: 60,
                                    dataRowMaxHeight: double.infinity,
                                    headingRowHeight: 200,
                                    columns: [
                                      const DataColumn(
                                        label: Text(
                                          'Features',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      ...products.map(
                                        (product) => DataColumn(
                                          label: _ProductHeader(
                                            product: product,
                                            onRemove: () => compareProvider.removeProduct(product.id),
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: [
                                      // Price row
                                      DataRow(
                                        cells: [
                                          const DataCell(Text(
                                            'Price',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )),
                                          ...products.map(
                                            (product) => DataCell(
                                              Text(
                                                '₱${product.price.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Brand row
                                      DataRow(
                                        cells: [
                                          const DataCell(Text(
                                            'Brand',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )),
                                          ...products.map(
                                            (product) => DataCell(Text(product.brand)),
                                          ),
                                        ],
                                      ),

                                      // Availability row
                                      DataRow(
                                        cells: [
                                          const DataCell(Text(
                                            'Availability',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )),
                                          ...products.map(
                                            (product) => DataCell(
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 12,
                                                    height: 12,
                                                    decoration: BoxDecoration(
                                                      color: product.inStock
                                                          ? Colors.green
                                                          : Colors.red,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(product.inStock
                                                      ? 'In Stock'
                                                      : 'Out of Stock'),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Specification rows
                                      ...sortedSpecs.map(
                                        (specKey) => DataRow(
                                          cells: [
                                            DataCell(Text(
                                              specKey,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            )),
                                            ...products.map(
                                              (product) => DataCell(
                                                Container(
                                                  constraints: const BoxConstraints(maxWidth: 200),
                                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                                  child: Text(
                                                    product.specifications[specKey] ?? '—',
                                                    maxLines: 3,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductHeader extends StatelessWidget {
  final Product product;
  final VoidCallback onRemove;

  const _ProductHeader({
    Key? key,
    required this.product,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 100,
            margin: const EdgeInsets.only(bottom: 8),
            child: Image.network(
              product.image ?? 'https://via.placeholder.com/150',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_not_supported),
            ),
          ),
          Text(
            product.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: onRemove,
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Remove', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
