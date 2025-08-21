import 'package:flutter/material.dart';
import 'package:smart_stock/models/stock_movement.dart';
import 'package:smart_stock/services/stock_service.dart';

class StockProvider with ChangeNotifier {
  final StockService _stockService;
  List<StockMovement> _movements = [];
  List<StockMovement> _filteredMovements = [];
  bool _isLoading = false;
  String? _error;
  StockMovementType? _currentFilter;
  Map<String, dynamic> _movementStats = {};

  StockProvider(this._stockService);

  // Getters
  List<StockMovement> get movements => _movements;
  List<StockMovement> get filteredMovements => _filteredMovements;
  bool get isLoading => _isLoading;
  String? get error => _error;
  StockMovementType? get currentFilter => _currentFilter;
  Map<String, dynamic> get movementStats => _movementStats;

  // Charger tous les mouvements
  Future<void> loadMovements() async {
    try {
      _setLoading(true);
      _error = null;
      _movements = await _stockService.getMovements();
      _filteredMovements = List.from(_movements);
      _calculateStats();
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des mouvements: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Ajouter un mouvement
  Future<StockMovement> addMovement(StockMovement movement) async {
    try {
      _setLoading(true);
      final newMovement = await _stockService.addMovement(movement);
      _movements.insert(0, newMovement);

      // Appliquer le filtre actuel si nécessaire
      if (_currentFilter == null || newMovement.type == _currentFilter) {
        _filteredMovements.insert(0, newMovement);
      }

      _calculateStats();
      notifyListeners();
      return newMovement;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout du mouvement: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Filtrer les mouvements par type
  Future<void> filterMovements(StockMovementType? type) async {
    try {
      _setLoading(true);
      _currentFilter = type;

      if (type == null) {
        _filteredMovements = List.from(_movements);
      } else {
        _filteredMovements = await _stockService.getMovementsByType(type);
      }

      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du filtrage: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Obtenir les mouvements par produit
  Future<List<StockMovement>> getMovementsByProduct(String productId) async {
    try {
      return await _stockService.getMovementsByProduct(productId);
    } catch (e) {
      _error = 'Erreur lors de la récupération par produit: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Obtenir les mouvements par plage de dates
  Future<List<StockMovement>> getMovementsByDateRange(DateTime start, DateTime end) async {
    try {
      return await _stockService.getMovementsByDateRange(start, end);
    } catch (e) {
      _error = 'Erreur lors de la récupération par date: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Obtenir les statistiques des mouvements
  Future<Map<String, dynamic>> getMovementStats() async {
    try {
      return await _stockService.getMovementStats();
    } catch (e) {
      _error = 'Erreur lors du calcul des statistiques: $e';
      notifyListeners();
      rethrow;
    }
  }

  // Calculer les statistiques locales
  void _calculateStats() {
    final entries = _movements.where((m) => m.type == StockMovementType.entry).length;
    final exits = _movements.where((m) => m.type == StockMovementType.exit).length;
    final adjustments = _movements.where((m) => m.type == StockMovementType.adjustment).length;
    final total = _movements.length;

    // Calculer les quantités totales
    final totalEntryQty = _movements
        .where((m) => m.type == StockMovementType.entry)
        .fold(0, (sum, m) => sum + m.quantity);

    final totalExitQty = _movements
        .where((m) => m.type == StockMovementType.exit)
        .fold(0, (sum, m) => sum + m.quantity);

    final totalAdjustmentQty = _movements
        .where((m) => m.type == StockMovementType.adjustment)
        .fold(0, (sum, m) => sum + m.quantity);

    _movementStats = {
      'entries': entries,
      'exits': exits,
      'adjustments': adjustments,
      'total': total,
      'totalEntryQty': totalEntryQty,
      'totalExitQty': totalExitQty,
      'totalAdjustmentQty': totalAdjustmentQty,
      'lastUpdate': DateTime.now(),
    };
  }

  // Obtenir le mouvement par ID
  StockMovement? getMovementById(String id) {
    try {
      return _movements.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtenir les mouvements récents (7 derniers jours)
  List<StockMovement> getRecentMovements() {
    final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _movements.where((m) => m.date.isAfter(oneWeekAgo)).toList();
  }

  // Obtenir l'historique d'un produit
  List<StockMovement> getProductHistory(String productId) {
    return _movements
        .where((m) => m.productId == productId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Vérifier si un produit a des mouvements
  bool hasMovementsForProduct(String productId) {
    return _movements.any((m) => m.productId == productId);
  }

  // Effacer le filtre
  void clearFilter() {
    _currentFilter = null;
    _filteredMovements = List.from(_movements);
    notifyListeners();
  }

  // Effacer les erreurs
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Réinitialiser l'état
  void reset() {
    _movements.clear();
    _filteredMovements.clear();
    _movementStats.clear();
    _currentFilter = null;
    _error = null;
    notifyListeners();
  }

  // Méthodes privées
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  // Méthode pour simuler un délai (utile pour les tests)
  Future<void> simulateDelay([Duration duration = const Duration(milliseconds: 500)]) async {
    await Future.delayed(duration);
  }

  // Vérifier si des données existent
  bool get hasData => _movements.isNotEmpty;

  // Obtenir le dernier mouvement
  StockMovement? get lastMovement => _movements.isNotEmpty ? _movements.first : null;

  // Obtenir le nombre total de mouvements
  int get totalCount => _movements.length;

  // Obtenir le nombre de mouvements filtrés
  int get filteredCount => _filteredMovements.length;

  // Vérifier si un filtre est actif
  bool get isFilterActive => _currentFilter != null;

  // Obtenir le stock actuel d'un produit (calcul basé sur les mouvements)
  int calculateCurrentStock(String productId) {
    final productMovements = _movements.where((m) => m.productId == productId);

    int stock = 0;
    for (final movement in productMovements) {
      switch (movement.type) {
        case StockMovementType.entry:
          stock += movement.quantity;
          break;
        case StockMovementType.exit:
          stock -= movement.quantity;
          break;
        case StockMovementType.adjustment:
          stock = movement.quantity; // Les ajustements définissent le stock directement
          break;
      }
    }

    return stock;
  }
}