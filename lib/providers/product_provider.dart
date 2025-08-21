import 'package:flutter/material.dart';
import 'package:smart_stock/models/product.dart';
import 'package:smart_stock/services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _searchQuery = '';
  String? _authToken;

  ProductProvider(this._productService);

  List<Product> get products => _products;
  List<Product> get filteredProducts => _filteredProducts;
  String get searchQuery => _searchQuery;

  void updateAuthToken(String? token) {
    _authToken = token;
  }

  Future<void> loadProducts() async {
    try {
      _products = await _productService.getProducts(_authToken);
      _filterProducts(_searchQuery);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  void filterProducts(String query) {
    _searchQuery = query;
    _filterProducts(query);
    notifyListeners();
  }

  void _filterProducts(String query) {
    if (query.isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
      _filteredProducts = _products.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.reference.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final newProduct = await _productService.addProduct(product, _authToken);
      _products.add(newProduct);
      _filterProducts(_searchQuery);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _productService.updateProduct(product, _authToken);
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        _filterProducts(_searchQuery);
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }
}