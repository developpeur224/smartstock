import 'package:smart_stock/config/constants.dart';
import 'package:smart_stock/models/sale.dart';
import 'package:smart_stock/utils/date_formatter.dart';

class SalesService {
  // Données statiques de démonstration
  final List<Sale> _mockSales = [
    Sale(
      id: 'SALE-001',
      date: DateTime.now().subtract(const Duration(days: 2)),
      clientName: 'Client Premium',
      items: [
        SaleItem(
          productId: 'PROD-1001',
          productName: 'Ordinateur Portable Pro',
          quantity: 1,
          unitPrice: 1299.99,
          notes: 'Configuration haut de gamme',
        ),
      ],
      isPaid: true,
      paymentMethod: PaymentTypes.card,
      reference: 'INV-${DateTime.now().subtract(const Duration(days: 2)).millisecondsSinceEpoch}',
      syncStatus: SyncStatus.synced,
    ),
    Sale(
      id: 'SALE-002',
      date: DateTime.now().subtract(const Duration(days: 1)),
      clientName: 'Client Standard',
      items: [
        SaleItem(
            productId: 'PROD-2001',
            productName: 'Smartphone Flagship',
            quantity: 2,
            unitPrice: 899.99,
            notes: 'Configuration bien passé'
        ),
        SaleItem(
            productId: 'PROD-3001',
            productName: 'Écran 27" 4K',
            quantity: 1,
            unitPrice: 399.99,
            notes: 'configuration'
        ),
      ],
      isPaid: false,
      paymentMethod: PaymentTypes.transfer,
      reference: 'INV-${DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch}',
      syncStatus: SyncStatus.synced,
    ),
    Sale(
      id: 'SALE-003',
      date: DateTime.now(),
      clientName: 'Client Entreprise',
      items: [
        SaleItem(
          productId: 'PROD-1001',
          productName: 'Ordinateur Portable Pro',
          quantity: 5,
          unitPrice: 1199.99,
          notes: 'Remise volume appliquée',
        ),
      ],
      isPaid: true,
      paymentMethod: PaymentTypes.transfer,
      reference: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      syncStatus: SyncStatus.pending,
    ),
  ];

  Future<List<Sale>> getSales([String? _]) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_mockSales);
  }

  Future<Sale> addSale(Sale sale, [String? _]) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Validation des données
    _validateSale(sale);

    final newSale = sale.copyWith(
      id: 'SALE-${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      reference: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      syncStatus: SyncStatus.pending,
    );

    _mockSales.insert(0, newSale);
    return newSale;
  }

  Future<List<Sale>> getSalesByPeriod(DateTime start, DateTime end) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockSales.where((sale) =>
    !sale.date.isBefore(start) && !sale.date.isAfter(end)
    ).toList();
  }

  Future<Map<String, dynamic>> getSalesStats() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final totalSales = _mockSales.length;
    final totalAmount = _mockSales.fold(0.0, (sum, sale) => sum + sale.totalAmount);
    final paidSales = _mockSales.where((s) => s.isPaid).length;

    return {
      'totalSales': totalSales,
      'totalAmount': totalAmount,
      'averageSale': totalSales > 0 ? totalAmount / totalSales : 0,
      'paidSales': paidSales,
      'unpaidSales': totalSales - paidSales,
      'lastSaleDate': _mockSales.isNotEmpty
          ? DateFormatter.formatDate(_mockSales.first.date)
          : null,
    };
  }

  Future<List<Sale>> getPendingSyncSales() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockSales.where((sale) => sale.syncStatus == SyncStatus.pending).toList();
  }

  Future<void> syncPendingSales([String? _]) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final pendingSales = await getPendingSyncSales();
    for (final sale in pendingSales) {
      final index = _mockSales.indexWhere((s) => s.id == sale.id);
      if (index != -1) {
        _mockSales[index] = sale.copyWith(syncStatus: SyncStatus.synced);
      }
    }
  }

  Future<List<Map<String, dynamic>>> getDailySalesReport() async {
    await Future.delayed(const Duration(milliseconds: 600));

    final Map<String, Map<String, dynamic>> dailySales = {};

    for (final sale in _mockSales) {
      final dateKey = DateFormatter.formatDate(sale.date);
      dailySales.update(
        dateKey,
            (existing) => {
          'date': dateKey,
          'count': existing['count'] + 1,
          'amount': existing['amount'] + sale.totalAmount,
        },
        ifAbsent: () => {
          'date': dateKey,
          'count': 1,
          'amount': sale.totalAmount,
        },
      );
    }

    return dailySales.values.toList()
      ..sort((a, b) => b['date'].compareTo(a['date']));
  }

  // Méthodes privées
  void _validateSale(Sale sale) {
    if (sale.items.isEmpty) {
      throw ArgumentError('Une vente doit contenir au moins un article');
    }

    if (sale.totalAmount < AppConstants.minSaleAmount ||
        sale.totalAmount > AppConstants.maxSaleAmount) {
      throw ArgumentError(
          'Le montant total doit être entre '
              '${AppConstants.minSaleAmount} et ${AppConstants.maxSaleAmount}'
      );
    }

    if (sale.items.any((item) => item.quantity > AppConstants.maxProductQuantity)) {
      throw ArgumentError(
          'La quantité d\'un article ne peut excéder ${AppConstants.maxProductQuantity}'
      );
    }
  }

  // Méthodes supplémentaires utiles
  Future<List<Sale>> getSalesByPaymentMethod(String paymentMethod) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockSales.where((sale) => sale.paymentMethod == paymentMethod).toList();
  }

  Future<List<Sale>> getUnpaidSales() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockSales.where((sale) => !sale.isPaid).toList();
  }

  Future<void> markAsPaid(String saleId, String paymentMethod) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockSales.indexWhere((sale) => sale.id == saleId);
    if (index != -1) {
      _mockSales[index] = _mockSales[index].copyWith(
        isPaid: true,
        paymentMethod: paymentMethod,
      );
    }
  }

  Future<Map<String, dynamic>> getPaymentMethodsStats() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final Map<String, dynamic> stats = {
      'totalByMethod': {},
      'countByMethod': {},
    };

    for (final sale in _mockSales) {
      final method = sale.paymentMethod ?? PaymentTypes.other;

      // Total par méthode de paiement
      stats['totalByMethod'][method] =
          (stats['totalByMethod'][method] ?? 0.0) + sale.totalAmount;

      // Nombre de ventes par méthode
      stats['countByMethod'][method] =
          (stats['countByMethod'][method] ?? 0) + 1;
    }

    return stats;
  }
}