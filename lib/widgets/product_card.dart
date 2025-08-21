import 'package:flutter/material.dart';
import 'package:smart_stock/config/constants.dart';
import 'package:smart_stock/models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                  child: Image.network(product.imageUrl!, fit: BoxFit.cover),
                )
                    : Icon(Icons.inventory_2, color: Colors.grey[400]),
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Réf: ${product.reference}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${product.price.toStringAsFixed(2)} ${AppConstants.defaultCurrency}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stock: ${product.quantity}',
                    style: TextStyle(
                      color: product.quantity <= product.alertQuantity
                          ? AppConstants.errorColor
                          : Colors.grey[600],
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