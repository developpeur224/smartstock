import 'package:flutter/material.dart';

class StockMovement {
  final String id;
  final String productId;
  final String productName;
  final StockMovementType type;
  final int quantity;
  final DateTime date;
  final String? reference;
  final String? notes;

  StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.date,
    this.reference,
    this.notes,
  });

  // Méthode pour créer une copie avec certaines valeurs modifiées
  StockMovement copyWith({
    String? id,
    String? productId,
    String? productName,
    StockMovementType? type,
    int? quantity,
    DateTime? date,
    String? reference,
    String? notes,
  }) {
    return StockMovement(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      date: date ?? this.date,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
    );
  }

  // Convertir en Map pour la sérialisation
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'type': type.index,
      'quantity': quantity,
      'date': date.toIso8601String(),
      'reference': reference,
      'notes': notes,
    };
  }

  // Créer à partir d'une Map (désérialisation)
  factory StockMovement.fromMap(Map<String, dynamic> map) {
    return StockMovement(
      id: map['id'],
      productId: map['productId'],
      productName: map['productName'],
      type: StockMovementType.values[map['type']],
      quantity: map['quantity'],
      date: DateTime.parse(map['date']),
      reference: map['reference'],
      notes: map['notes'],
    );
  }
}

enum StockMovementType {
  entry('Entrée', Icons.arrow_downward, Colors.green, '+'),
  exit('Sortie', Icons.arrow_upward, Colors.red, '-'),
  adjustment('Ajustement', Icons.tune, Colors.orange, '±');

  final String displayName;
  final IconData icon;
  final Color color;
  final String prefix;

  const StockMovementType(
      this.displayName,
      this.icon,
      this.color,
      this.prefix,
      );
}

// Extension pour les fonctionnalités supplémentaires
extension StockMovementTypeExtension on StockMovementType {
  String get formattedName => displayName;
  IconData get iconData => icon;
  Color get colorType => color;
  String get quantityPrefix => prefix;
}