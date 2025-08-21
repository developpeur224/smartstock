import 'package:smart_stock/models/stock_movement.dart';

class StockService {
  // Données fictives pour les tests
  final List<StockMovement> _mockMovements = [
    StockMovement(
      id: 'MOVE-001',
      productId: 'PROD-1001',
      productName: 'Ordinateur Portable Pro',
      type: StockMovementType.entry,
      quantity: 10,
      date: DateTime.now().subtract(const Duration(days: 2)),
      reference: 'REF-001',
      notes: 'Commande fournisseur',
    ),
    StockMovement(
      id: 'MOVE-002',
      productId: 'PROD-1002',
      productName: 'Smartphone Flagship',
      type: StockMovementType.exit,
      quantity: 2,
      date: DateTime.now().subtract(const Duration(days: 1)),
      reference: 'SALE-001',
      notes: 'Vente client',
    ),
    StockMovement(
      id: 'MOVE-003',
      productId: 'PROD-1003',
      productName: 'Écran 27" 4K',
      type: StockMovementType.entry,
      quantity: 5,
      date: DateTime.now().subtract(const Duration(hours: 12)),
      reference: 'REF-002',
      notes: 'Réapprovisionnement',
    ),
    StockMovement(
      id: 'MOVE-004',
      productId: 'PROD-1001',
      productName: 'Ordinateur Portable Pro',
      type: StockMovementType.exit,
      quantity: 1,
      date: DateTime.now().subtract(const Duration(hours: 6)),
      reference: 'SALE-002',
      notes: 'Vente en ligne',
    ),
    StockMovement(
      id: 'MOVE-005',
      productId: 'PROD-1004',
      productName: 'Souris Sans Fil',
      type: StockMovementType.adjustment,
      quantity: 3,
      date: DateTime.now().subtract(const Duration(hours: 3)),
      reference: 'ADJ-001',
      notes: 'Correction inventaire',
    ),
  ];

  Future<List<StockMovement>> getMovements([String? _]) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_mockMovements);
  }

  Future<StockMovement> addMovement(StockMovement movement, [String? _]) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Validation
    _validateMovement(movement);

    final newMovement = movement.copyWith(
      id: 'MOVE-${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
    );

    _mockMovements.insert(0, newMovement);
    return newMovement;
  }

  Future<List<StockMovement>> getMovementsByType(StockMovementType? type, [String? _]) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (type == null) return List.from(_mockMovements);
    return _mockMovements.where((m) => m.type == type).toList();
  }

  Future<List<StockMovement>> getMovementsByProduct(String productId, [String? _]) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockMovements.where((m) => m.productId == productId).toList();
  }

  Future<List<StockMovement>> getMovementsByDateRange(DateTime start, DateTime end, [String? _]) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockMovements.where((m) =>
    m.date.isAfter(start) && m.date.isBefore(end)
    ).toList();
  }

  Future<Map<String, dynamic>> getMovementStats([String? _]) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final totalMovements = _mockMovements.length;
    final entryCount = _mockMovements.where((m) => m.type == StockMovementType.entry).length;
    final exitCount = _mockMovements.where((m) => m.type == StockMovementType.exit).length;
    final adjustmentCount = _mockMovements.where((m) => m.type == StockMovementType.adjustment).length;

    return {
      'totalMovements': totalMovements,
      'entryCount': entryCount,
      'exitCount': exitCount,
      'adjustmentCount': adjustmentCount,
      'lastMovementDate': _mockMovements.isNotEmpty ? _mockMovements.first.date : null,
    };
  }

  // Méthodes privées
  void _validateMovement(StockMovement movement) {
    if (movement.quantity <= 0) {
      throw ArgumentError('La quantité doit être supérieure à 0');
    }

    if (movement.productName.isEmpty) {
      throw ArgumentError('Le nom du produit est requis');
    }

    if (movement.productId.isEmpty) {
      throw ArgumentError('L\'ID du produit est requis');
    }
  }
}