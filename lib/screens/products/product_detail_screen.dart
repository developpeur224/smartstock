import 'package:flutter/material.dart';
import 'package:smart_stock/config/constants.dart';
import 'package:smart_stock/models/product.dart';
import 'package:smart_stock/widgets/custom_button.dart';
import 'package:smart_stock/config/routes.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du Produit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.editProduct,
              arguments: product,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du produit
            _buildProductImage(),
            const SizedBox(height: 20),

            // Nom et prix
            _buildProductHeader(),
            const SizedBox(height: 16),

            // Référence et statut du stock
            _buildReferenceAndStockStatus(),
            const SizedBox(height: 16),

            // Description
            if (product.description != null && product.description!.isNotEmpty)
              _buildDescription(),
            if (product.description != null && product.description!.isNotEmpty)
              const SizedBox(height: 20),

            // Informations supplémentaires
            _buildAdditionalInfo(),
            const SizedBox(height: 30),

            // Actions
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: product.imageUrl != null && product.imageUrl!.isNotEmpty
          ? ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          product.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      )
          : const Center(
        child: Icon(Icons.inventory_2, size: 60, color: Colors.grey),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            product.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          '${product.price.toStringAsFixed(2)} ${AppConstants.defaultCurrency}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceAndStockStatus() {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (product.quantity == 0) {
      statusColor = Colors.red;
      statusText = 'Rupture de stock';
      statusIcon = Icons.error_outline;
    } else if (product.quantity <= product.alertQuantity) {
      statusColor = Colors.orange;
      statusText = 'Stock faible';
      statusIcon = Icons.warning_amber_rounded;
    } else {
      statusColor = Colors.green;
      statusText = 'En stock';
      statusIcon = Icons.check_circle_outline;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Référence
        Text(
          'Référence: ${product.reference}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),

        // Statut du stock
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(statusIcon, size: 16, color: statusColor),
                  const SizedBox(width: 6),
                  Text(
                    '$statusText (${product.quantity})',
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              'Seuil d\'alerte: ${product.alertQuantity}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.description!,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildInfoRow('ID Produit', product.id),
          const SizedBox(height: 12),
          _buildInfoRow('Catégorie', product.categoryId ?? 'Non catégorisé'),
          const SizedBox(height: 12),
          _buildInfoRow('Fournisseur', product.supplierId ?? 'Non spécifié'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Modifier le stock',
            onPressed: ()=> Navigator.pushNamed(
              context,
              AppRoutes.editProduct,
              arguments: product,
            ),
            variant: ButtonVariant.outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: 'Vendre',
            onPressed: product.quantity > 0
                ? () {
              // Navigation vers l'écran de vente
              // Navigator.push(context, MaterialPageRoute(builder: (context) => SaleFormScreen(product: product)));
            }
                : null,
          ),
        ),
      ],
    );
  }
}