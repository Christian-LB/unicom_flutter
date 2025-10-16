import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/navigation_bar.dart';
import '../widgets/product_card.dart';
import '../providers/product_provider.dart';
import '../theme/colors.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({Key? key}) : super(key: key);

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomNavigationBar(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 973),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: Consumer<ProductProvider>(
                    builder: (context, productProvider, child) {
                      return Column(
                        children: [
                          // Search and filters
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Search bar
                                TextField(
                                  controller: _searchController,
                                  decoration: const InputDecoration(
                                    hintText: 'Search products...',
                                    prefixIcon: Icon(Icons.search),
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    productProvider.searchProducts(value);
                                  },
                                ),
                                const SizedBox(height: 16),
                                
                                // Category filter
                                if (productProvider.categories.isNotEmpty)
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        FilterChip(
                                          label: const Text('All'),
                                          selected: productProvider.selectedCategory == null,
                                          onSelected: (selected) {
                                            if (selected) {
                                              productProvider.clearFilters();
                                            }
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        ...productProvider.categories.map((category) {
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: FilterChip(
                                              label: Text(category),
                                              selected: productProvider.selectedCategory == category,
                                              onSelected: (selected) {
                                                if (selected) {
                                                  productProvider.filterByCategory(category);
                                                } else {
                                                  productProvider.clearFilters();
                                                }
                                              },
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          
                          // Products grid
                          Expanded(
                            child: productProvider.isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : productProvider.error != null
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.error_outline,
                                              size: 64,
                                              color: AppColors.error,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              productProvider.error!,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: AppColors.error,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: () {
                                                productProvider.loadProducts();
                                              },
                                              child: const Text('Retry'),
                                            ),
                                          ],
                                        ),
                                      )
                                    : productProvider.products.isEmpty
                                        ? const Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.inventory_2_outlined,
                                                  size: 64,
                                                  color: AppColors.mutedForeground,
                                                ),
                                                SizedBox(height: 16),
                                                Text(
                                                  'No products found',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: AppColors.mutedForeground,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : GridView.builder(
                                            padding: const EdgeInsets.all(16),
                                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              childAspectRatio: 0.8,
                                              crossAxisSpacing: 16,
                                              mainAxisSpacing: 16,
                                            ),
                                            itemCount: productProvider.products.length,
                                            itemBuilder: (context, index) {
                                              final product = productProvider.products[index];
                                              return ProductCard(product: product);
                                            },
                                          ),
                          ),
                        ],
                      );
                    },
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
