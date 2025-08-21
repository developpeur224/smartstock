import 'package:flutter/material.dart';
import 'package:smart_stock/models/sale.dart';
import 'package:smart_stock/services/sales_service.dart';

class SalesProvider with ChangeNotifier {
  final SalesService _salesService;
  List<Sale> _sales = [];
  List<Sale> _filteredSales = [];
  bool _isLoading = false;
  String? _error;
  DateTimeRange? _dateFilter;

  SalesProvider(this._salesService);

  List<Sale> get sales => _sales;
  List<Sale> get filteredSales => _filteredSales;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTimeRange? get dateFilter => _dateFilter;

  Future<void> loadSales() async {
    try {
      _setLoading(true);
      _error = null;
      _sales = await _salesService.getSales();
      _filteredSales = List.from(_sales);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du chargement des ventes: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Sale> addSale(Sale sale) async {
    try {
      _setLoading(true);
      final newSale = await _salesService.addSale(sale);
      _sales.insert(0, newSale);
      _filteredSales.insert(0, newSale);
      notifyListeners();
      return newSale;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout de la vente: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> filterSalesByDate(DateTime start, DateTime end) async {
    try {
      _setLoading(true);
      _dateFilter = DateTimeRange(start: start, end: end);
      _filteredSales = await _salesService.getSalesByPeriod(start, end);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du filtrage: $e';
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markAsPaid(String saleId, String paymentMethod) async {
    try {
      await _salesService.markAsPaid(saleId, paymentMethod);
      final index = _sales.indexWhere((s) => s.id == saleId);
      if (index != -1) {
        _sales[index] = _sales[index].copyWith(isPaid: true, paymentMethod: paymentMethod);
        _filteredSales = List.from(_sales);
      }
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors du marquage comme payé: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSalesStats() async {
    try {
      return await _salesService.getSalesStats();
    } catch (e) {
      _error = 'Erreur lors du calcul des statistiques: $e';
      notifyListeners();
      rethrow;
    }
  }

  void clearDateFilter() {
    _dateFilter = null;
    _filteredSales = List.from(_sales);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }
}