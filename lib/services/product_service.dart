import 'package:smart_stock/config/constants.dart';
import 'package:smart_stock/models/product.dart';

class ProductService {
  // Données fictives pour les tests
  final List<Product> _mockProducts = [
    Product(
      id: 'PROD-1001',
      name: 'Ordinateur Portable Pro',
      reference: 'REF-1001',
      description: 'Ordinateur portable haut de gamme 16GB RAM, 512GB SSD',
      price: 1299.99,
      quantity: 15,
      alertQuantity: 5,
      categoryId: 'CAT-001',
      supplierId: 'SUPP-001',
      imageUrl: null,
    ),
    Product(
      id: 'PROD-1002',
      name: 'Smartphone Flagship',
      reference: 'REF-1002',
      description: 'Smartphone dernier cri avec caméra 108MP',
      price: 899.99,
      quantity: 25,
      alertQuantity: 3,
      categoryId: 'CAT-002',
      supplierId: 'SUPP-002',
      imageUrl: null,
    ),
    Product(
      id: 'PROD-1003',
      name: 'Écran 27" 4K',
      reference: 'REF-1003',
      description: 'Écran 27 pouces résolution 4K UHD',
      price: 399.99,
      quantity: 8,
      alertQuantity: 2,
      categoryId: 'CAT-003',
      supplierId: 'SUPP-001',
      imageUrl: null,
    ),
    Product(
      id: 'PROD-1004',
      name: 'Souris Sans Fil',
      reference: 'REF-1004',
      description: 'Souris ergonomique sans fil',
      price: 49.99,
      quantity: 50,
      alertQuantity: 10,
      categoryId: 'CAT-004',
      supplierId: 'SUPP-003',
      imageUrl: null,
    ),
    Product(
      id: 'PROD-1005',
      name: 'Clavier Mécanique',
      reference: 'REF-1005',
      description: 'Clavier mécanique rétroéclairé RGB',
      price: 129.99,
      quantity: 12,
      alertQuantity: 4,
      categoryId: 'CAT-004',
      supplierId: 'SUPP-002',
      imageUrl: null,
    ),
    Product(
      id: 'PROD-1006',
      name: 'Casque Gaming',
      reference: 'REF-1006',
      description: 'Casque gaming 7.1 surround sound',
      price: 159.99,
      quantity: 6,
      alertQuantity: 3,
      categoryId: 'CAT-005',
      supplierId: 'SUPP-003',
      imageUrl: null,
    ),
    Product(
      id: 'PROD-1007',
      name: 'Disque Dur Externe 1TB',
      reference: 'REF-1007',
      description: 'Disque dur externe portable USB 3.0',
      price: 79.99,
      quantity: 18,
      alertQuantity: 5,
      categoryId: 'CAT-006',
      supplierId: 'SUPP-001',
      imageUrl: null,
    ),
    Product(
      id: 'PROD-1008',
      name: 'Webcam HD',
      reference: 'REF-1008',
      description: 'Webcam 1080p avec micro intégré',
      price: 69.99,
      quantity: 0,
      alertQuantity: 20,
      categoryId: 'CAT-007',
      supplierId: 'SUPP-004',
      imageUrl: null,
    ),
    Product(
      id: 'PROD-1009',
      name: 'Enceinte Bluetooth',
      reference: 'REF-1009',
      description: 'Enceinte portable étanche',
      price: 89.99,
      quantity: 22,
      alertQuantity: 8,
      categoryId: 'CAT-008',
      supplierId: 'SUPP-004',
      imageUrl: null,
    ),
    Product(
      id: 'PROD-1010',
      name: 'Chargeur Rapide',
      reference: 'REF-1010',
      description: 'Chargeur rapide 65W USB-C',
      price: 39.99,
      quantity: 35,
      alertQuantity: 15,
      categoryId: 'CAT-009',
      supplierId: 'SUPP-005',
      imageUrl: null,
    ),
  ];

  Future<List<Product>> getProducts([String? _]) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return List.from(_mockProducts);
  }

  Future<Product> getProductById(String productId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final product = _mockProducts.firstWhere(
          (product) => product.id == productId,
      orElse: () => throw Exception('Produit non trouvé'),
    );
    return product;
  }

  Future<List<Product>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (query.isEmpty) return List.from(_mockProducts);

    return _mockProducts.where((product) =>
    product.name.toLowerCase().contains(query.toLowerCase()) ||
        product.reference.toLowerCase().contains(query.toLowerCase()) ||
        (product.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }

  Future<List<Product>> getLowStockProducts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockProducts.where((product) =>
    product.quantity <= product.alertQuantity
    ).toList();
  }

  Future<Product> addProduct(Product product, [String? _]) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // Validation des données
    _validateProduct(product);

    final newProduct = product.copyWith(
      id: 'PROD-${DateTime.now().millisecondsSinceEpoch}',
    );

    _mockProducts.add(newProduct);
    return newProduct;
  }

  Future<void> updateProduct(Product product, [String? _]) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Validation des données
    _validateProduct(product);

    final index = _mockProducts.indexWhere((p) => p.id == product.id);
    if (index == -1) {
      throw Exception('Produit non trouvé');
    }

    _mockProducts[index] = product;
  }

  Future<void> deleteProduct(String productId, [String? _]) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final index = _mockProducts.indexWhere((p) => p.id == productId);
    if (index == -1) {
      throw Exception('Produit non trouvé');
    }

    _mockProducts.removeAt(index);
  }

  Future<void> updateStock(String productId, int quantityChange, [String? _]) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockProducts.indexWhere((p) => p.id == productId);
    if (index == -1) {
      throw Exception('Produit non trouvé');
    }

    final currentProduct = _mockProducts[index];
    final newQuantity = currentProduct.quantity + quantityChange;

    if (newQuantity < 0) {
      throw Exception('Stock insuffisant');
    }

    _mockProducts[index] = currentProduct.copyWith(quantity: newQuantity);
  }

  Future<Map<String, dynamic>> getProductsStats() async {
    await Future.delayed(const Duration(milliseconds: 600));

    final totalProducts = _mockProducts.length;
    final totalStockValue = _mockProducts.fold(0.0, (sum, product) =>
    sum + (product.price * product.quantity)
    );
    final lowStockCount = _mockProducts.where((p) =>
    p.quantity <= p.alertQuantity
    ).length;
    final outOfStockCount = _mockProducts.where((p) =>
    p.quantity == 0
    ).length;

    return {
      'totalProducts': totalProducts,
      'totalStockValue': totalStockValue,
      'averagePrice': totalProducts > 0 ?
      _mockProducts.fold(0.0, (sum, product) => sum + product.price) / totalProducts : 0,
      'lowStockCount': lowStockCount,
      'outOfStockCount': outOfStockCount,
      'totalQuantity': _mockProducts.fold(0, (sum, product) => sum + product.quantity),
    };
  }

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockProducts.where((product) =>
    product.categoryId == categoryId
    ).toList();
  }

  Future<List<Product>> getProductsBySupplier(String supplierId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockProducts.where((product) =>
    product.supplierId == supplierId
    ).toList();
  }

  // Méthodes privées
  void _validateProduct(Product product) {
    if (product.name.isEmpty) {
      throw ArgumentError('Le nom du produit est requis');
    }

    if (product.reference.isEmpty) {
      throw ArgumentError('La référence du produit est requise');
    }

    if (product.price <= 0) {
      throw ArgumentError('Le prix doit être supérieur à 0');
    }

    if (product.quantity < 0) {
      throw ArgumentError('La quantité ne peut pas être négative');
    }

    if (product.alertQuantity < 0) {
      throw ArgumentError('La quantité d\'alerte ne peut pas être négative');
    }

    if (product.name.length > 100) {
      throw ArgumentError('Le nom du produit est trop long');
    }

    if (product.reference.length > 50) {
      throw ArgumentError('La référence du produit est trop longue');
    }
  }
}