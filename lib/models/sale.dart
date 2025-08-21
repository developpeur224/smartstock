import 'package:smart_stock/config/constants.dart';

class Sale {
  final String id;
  final DateTime date;
  final String clientName;
  final List<SaleItem> items;
  final bool isPaid;
  final String? notes;
  final String? paymentMethod; // Changed from PaymentTypes to String
  final String? reference;
  final String syncStatus; // Changed from SyncStatus to String

  double get totalAmount => items.fold(
    0.0,
        (sum, item) => sum + (item.quantity * item.unitPrice),
  );

  Sale({
    required this.id,
    required this.date,
    required this.clientName,
    required this.items,
    this.isPaid = false,
    this.notes,
    this.paymentMethod,
    this.reference,
    this.syncStatus = SyncStatus.pending, // Using string constant
  });
}

extension SaleExtensions on Sale {
  Sale copyWith({
    String? syncStatus,
    bool? isPaid,
    String? notes,
    String? paymentMethod,
    String? reference,
    DateTime? date,
    String? id,
  }) {
    return Sale(
      id: id ?? this.id,
      date: date ?? this.date,
      clientName: clientName,
      items: items,
      isPaid: isPaid ?? this.isPaid,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      reference: reference ?? this.reference,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}

class SaleItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final String notes;

  double get totalPrice => quantity * unitPrice;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.notes,
  });
}