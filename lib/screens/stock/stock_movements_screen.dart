import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stock/config/constants.dart';
import 'package:smart_stock/models/stock_movement.dart';
import 'package:smart_stock/providers/stock_provider.dart';
import 'package:smart_stock/utils/date_formatter.dart';
import 'package:smart_stock/widgets/movement_stats_card.dart';

class StockMovementsScreen extends StatefulWidget {
  const StockMovementsScreen({super.key});

  @override
  State<StockMovementsScreen> createState() => _StockMovementsScreenState();
}

class _StockMovementsScreenState extends State<StockMovementsScreen> {
  StockMovementType? _filterType;
  final _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    // Charger les données après que le build soit complété
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
      await Provider.of<StockProvider>(context, listen: false).loadMovements();
    } catch (e) {
      print('Erreur lors du chargement: $e');
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

  @override
  Widget build(BuildContext context) {
    final stockProvider = Provider.of<StockProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mouvements de stock'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadData,
          ),
          _buildFilterMenu(stockProvider),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(stockProvider, theme),
    );
  }

  Widget _buildFilterMenu(StockProvider stockProvider) {
    return PopupMenuButton<StockMovementType>(
      icon: const Icon(Icons.filter_list),
      onSelected: (type) async {
        setState(() => _filterType = type);
        await stockProvider.filterMovements(type);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: null,
          child: Text('Tous les mouvements'),
        ),
        ...StockMovementType.values.map((type) => PopupMenuItem(
          value: type,
          child: Row(
            children: [
              Icon(type.icon, color: type.color),
              const SizedBox(width: 10),
              Text(type.displayName),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildContent(StockProvider stockProvider, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          const SliverToBoxAdapter(
            child: MovementStatsCard(),
          ),
          _buildMovementsList(stockProvider, theme),
        ],
      ),
    );
  }

  Widget _buildMovementsList(StockProvider stockProvider, ThemeData theme) {
    final movements = stockProvider.filteredMovements;

    if (movements.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Text(
            _filterType == null
                ? 'Aucun mouvement enregistré'
                : 'Aucun ${_filterType!.displayName.toLowerCase()}',
            style: theme.textTheme.titleMedium,
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final movement = movements[index];
          return _buildMovementCard(movement, theme);
        },
        childCount: movements.length,
      ),
    );
  }

  // ... le reste du code reste inchangé
  Widget _buildMovementCard(StockMovement movement, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        onTap: () => _showMovementDetails(movement),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: movement.type.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(movement.type.icon, color: movement.type.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movement.productName,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${movement.type.prefix}${movement.quantity} unités',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormatter.formatDate(movement.date),
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormatter.formatTime(movement.date),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMovementDetails(StockMovement movement) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
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
              children: [
                Icon(movement.type.icon, color: movement.type.color),
                const SizedBox(width: 8),
                Text(
                  movement.type.displayName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Produit', movement.productName),
            _buildDetailRow('Quantité', '${movement.type.prefix}${movement.quantity}'),
            _buildDetailRow('Date', DateFormatter.formatDateTime(movement.date)),
            if (movement.reference != null)
              _buildDetailRow('Référence', movement.reference!),
            if (movement.notes != null) _buildDetailRow('Notes', movement.notes!),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
}