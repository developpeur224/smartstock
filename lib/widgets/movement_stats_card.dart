import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stock/config/constants.dart';
import 'package:smart_stock/models/stock_movement.dart';
import 'package:smart_stock/providers/stock_provider.dart';

class MovementStatsCard extends StatelessWidget {
  const MovementStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final stockProvider = Provider.of<StockProvider>(context);
    final movements = stockProvider.movements;

    // Calculer les statistiques localement
    final entries = movements.where((m) => m.type == StockMovementType.entry).length;
    final exits = movements.where((m) => m.type == StockMovementType.exit).length;
    final adjustments = movements.where((m) => m.type == StockMovementType.adjustment).length;
    final total = movements.length;

    return Card(
      margin: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            const Text(
              'STATISTIQUES DES MOUVEMENTS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  value: entries,
                  label: 'Entrées',
                  color: StockMovementType.entry.color,
                ),
                _buildStatItem(
                  context,
                  value: exits,
                  label: 'Sorties',
                  color: StockMovementType.exit.color,
                ),
                _buildStatItem(
                  context,
                  value: adjustments,
                  label: 'Ajustements',
                  color: StockMovementType.adjustment.color,
                ),
                _buildStatItem(
                  context,
                  value: total,
                  label: 'Total',
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {
    required int value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Text(
            value.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}