class Product {
  final String id;
  final String name;
  final String reference;
  final String? description;
  final double price;
  final int quantity;
  final int alertQuantity;
  final String? categoryId;
  final String? supplierId;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.reference,
    this.description,
    required this.price,
    required this.quantity,
    this.alertQuantity = 5,
    this.categoryId,
    this.supplierId,
    this.imageUrl,
  });
}

enum SyncStatus { synced, pending }

extension ProductExtensions on Product {
  Product copyWith({
    String? id,
    String? name,
    String? reference,
    String? description,
    double? price,
    int? quantity,
    int? alertQuantity,
    String? categoryId,
    String? supplierId,
    String? imageUrl,
    SyncStatus? syncStatus,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      reference: reference ?? this.reference,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      alertQuantity: alertQuantity ?? this.alertQuantity,
      categoryId: categoryId ?? this.categoryId,
      supplierId: supplierId ?? this.supplierId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}