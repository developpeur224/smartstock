import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stock/config/constants.dart';
import 'package:smart_stock/config/routes.dart';
import 'package:smart_stock/models/sale.dart';
import 'package:smart_stock/providers/sales_provider.dart';
import 'package:smart_stock/utils/date_formatter.dart';
import 'package:smart_stock/widgets/sale_card.dart';

class SalesListScreen extends StatefulWidget {
  const SalesListScreen({super.key});

  @override
  State<SalesListScreen> createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
  final _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    // Charger les données après le build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<SalesProvider>(context, listen: false).loadSales();
    } catch (e) {
      print('Erreur lors du chargement des ventes: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // Charger plus d'éléments si nécessaire
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: Provider.of<SalesProvider>(context, listen: false).dateFilter,
    );

    if (picked != null) {
      await Provider.of<SalesProvider>(context, listen: false)
          .filterSalesByDate(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final salesProvider = Provider.of<SalesProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventes'),
        actions: [
          if (salesProvider.dateFilter != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                salesProvider.clearDateFilter();
              },
              tooltip: 'Effacer le filtre',
            ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
            tooltip: 'Filtrer par date',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadData,
            tooltip: 'Rafraîchir',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.addSale),
            tooltip: 'Nouvelle vente',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(salesProvider, theme),
    );
  }

  Widget _buildContent(SalesProvider salesProvider, ThemeData theme) {
    if (salesProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              salesProvider.error!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildStatsHeader(salesProvider),
          _buildSalesList(salesProvider, theme),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(SalesProvider salesProvider) {
    final sales = salesProvider.filteredSales;
    final totalAmount = sales.fold(0.0, (sum, sale) => sum + sale.totalAmount);
    final paidSales = sales.where((s) => s.isPaid).length;

    return SliverToBoxAdapter(
      child: Card(
        margin: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'RÉSUMÉ DES VENTES',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Total', '${sales.length}', Icons.receipt),
                  _buildStatItem('Payées', '$paidSales', Icons.check_circle),
                  _buildStatItem('Montant', '${totalAmount.toStringAsFixed(2)}€', Icons.euro),
                ],
              ),
              if (salesProvider.dateFilter != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Période: ${DateFormatter.formatDate(salesProvider.dateFilter!.start)} - ${DateFormatter.formatDate(salesProvider.dateFilter!.end)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSalesList(SalesProvider salesProvider, ThemeData theme) {
    final sales = salesProvider.filteredSales;

    if (sales.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.point_of_sale, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                salesProvider.dateFilter != null
                    ? 'Aucune vente dans cette période'
                    : 'Aucune vente enregistrée',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Commencez par ajouter votre première vente',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.addSale),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    'Nouvelle vente',
                    style: TextStyle(
                      color: Colors.white, // ← Ajoutez cette ligne
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final sale = sales[index];
          return SaleCard(
            sale: sale,
            onTap: () => _showSaleDetails(sale),
          );
        },
        childCount: sales.length,
      ),
    );
  }

  void _showSaleDetails(Sale sale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildSaleDetailsSheet(sale),
    );
  }

  Widget _buildSaleDetailsSheet(Sale sale) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Détails de la vente',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Chip(
                label: Text(sale.isPaid ? 'Payée' : 'Impayée'),
                backgroundColor: sale.isPaid ? Colors.green[100] : Colors.orange[100],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Référence', sale.reference ?? 'N/A'),
          _buildDetailRow('Client', sale.clientName),
          _buildDetailRow('Date', DateFormatter.formatDateTime(sale.date)),
          _buildDetailRow('Montant total', '${sale.totalAmount.toStringAsFixed(2)}€'),
          if (sale.paymentMethod != null)
            _buildDetailRow('Méthode de paiement', sale.paymentMethod!),

          const SizedBox(height: 16),
          const Text(
            'Articles:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...sale.items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text('• ${item.quantity}x ${item.productName} - ${item.totalPrice.toStringAsFixed(2)}€'),
          )),

          const SizedBox(height: 24),
          if (!sale.isPaid)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _markAsPaid(sale.id),
                child: const Text('Marquer comme payée', style: TextStyle(color: Colors.white)),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _markAsPaid(String saleId) async {
    try {
      await Provider.of<SalesProvider>(context, listen: false)
          .markAsPaid(saleId, 'cash');
      Navigator.pop(context); // Fermer le bottom sheet
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }
}