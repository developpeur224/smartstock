import 'package:flutter/material.dart';
import 'package:smart_stock/config/constants.dart';
import 'package:smart_stock/models/sale.dart';
import 'package:smart_stock/utils/date_formatter.dart';

class SaleCard extends StatelessWidget {
  final Sale sale;
  final VoidCallback onTap;

  const SaleCard({
    super.key,
    required this.sale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sale.clientName,
                    style: theme.textTheme.titleMedium,
                  ),
                  Chip(
                    label: Text(
                      sale.isPaid ? 'Payée' : 'Impayée',
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: sale.isPaid
                        ? Colors.green[100]
                        : Colors.orange[100],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${sale.items.length} article${sale.items.length > 1 ? 's' : ''} • ${sale.totalAmount.toStringAsFixed(2)}€',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormatter.formatDate(sale.date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  if (sale.paymentMethod != null)
                    Text(
                      sale.paymentMethod!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}