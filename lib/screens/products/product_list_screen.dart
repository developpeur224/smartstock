import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stock/config/constants.dart';
import 'package:smart_stock/config/routes.dart';
import 'package:smart_stock/providers/product_provider.dart';
import 'package:smart_stock/widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<ProductProvider>(context, listen: false).loadProducts();
    } catch (e) {
      print('Erreur lors du chargement: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.addProduct),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    productProvider.filterProducts('');
                  },
                ),
              ),
              onChanged: (value) => productProvider.filterProducts(value),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildProductList(productProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadProducts,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildProductList(ProductProvider productProvider) {
    final products = productProvider.filteredProducts;

    if (products.isEmpty) {
      return Center(
        child: Text(
          productProvider.searchQuery.isEmpty
              ? 'Aucun produit enregistré'
              : 'Aucun résultat trouvé',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.productDetails,
              arguments: product,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}