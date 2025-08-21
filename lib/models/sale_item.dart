import 'package:flutter/material.dart';
import 'package:smart_stock/config/constants.dart';

class SaleItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final String? notes;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.notes,
  }) : assert(quantity > 0 && quantity <= AppConstants.maxSaleItems,
  'La quantité doit être entre 1 et ${AppConstants.maxSaleItems}'),
        assert(unitPrice >= 0, 'Le prix unitaire ne peut pas être négatif');

  double get totalPrice => quantity * unitPrice;

  // Méthode pour créer une copie modifiée
  SaleItem copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    String? notes,
  }) {
    return SaleItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      notes: notes ?? this.notes,
    );
  }

  // Conversion en Map pour la sérialisation
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'notes': notes,
      'totalPrice': totalPrice,
    };
  }

  // Création à partir d'une Map
  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      quantity: map['quantity'] as int,
      unitPrice: map['unitPrice'] as double,
      notes: map['notes'] as String?,
    );
  }

  // Pour affichage dans les logs/debug
  @override
  String toString() {
    return 'SaleItem('
        'productId: $productId, '
        'productName: $productName, '
        'quantity: $quantity, '
        'unitPrice: ${unitPrice.toStringAsFixed(2)}${AppConstants.defaultCurrency}, '
        'total: ${totalPrice.toStringAsFixed(2)}${AppConstants.defaultCurrency}'
        ')';
  }
}

/// Extension pour les fonctionnalités supplémentaires
extension SaleItemExtensions on SaleItem {
  // Formatage du prix pour l'affichage
  String get formattedUnitPrice =>
      '${unitPrice.toStringAsFixed(2)}${AppConstants.defaultCurrency}';

  String get formattedTotalPrice =>
      '${totalPrice.toStringAsFixed(2)}${AppConstants.defaultCurrency}';

  // Widget d'affichage compact pour les listes
  Widget toListTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.shopping_basket, color: AppConstants.primaryColor),
      title: Text(productName),
      subtitle: Text('$quantity × $formattedUnitPrice'),
      trailing: Text(
        formattedTotalPrice,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}