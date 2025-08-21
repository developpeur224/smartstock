import 'package:flutter/material.dart';
import 'package:smart_stock/config/constants.dart';
import 'package:smart_stock/models/product.dart';
import 'package:smart_stock/widgets/custom_button.dart';
import 'package:smart_stock/widgets/custom_textfield.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

// Déplacez ces classes et variables en dehors de la classe State
class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});
}

// Créez une Map pour les catégories aussi
final Map<String, String> categoryMap = {
  'CAT-001': 'Électronique',
  'CAT-002': 'Vêtements',
  'CAT-003': 'Alimentation',
  'CAT-004': 'Meubles',
  'CAT-005': 'Fournitures de bureau',
};

final Map<String, String> supplierMap = {
  'SUP-001': 'TechCorp Inc.',
  'SUP-002': 'FashionStyle SARL',
  'SUP-003': 'FoodDistrib',
  'SUP-004': 'HomeDesign',
  'SUP-005': 'OfficeSupplies Co.',
};

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _referenceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _alertQuantityController = TextEditingController();

  String? _selectedCategory;
  String? _selectedSupplier;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Pré-remplir le formulaire si on est en mode édition
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _referenceController.text = widget.product!.reference;
      _descriptionController.text = widget.product!.description ?? '';
      _priceController.text = widget.product!.price.toString();
      _quantityController.text = widget.product!.quantity.toString();
      _alertQuantityController.text = widget.product!.alertQuantity.toString();

      // Corrigez les valeurs si nécessaire pour qu'elles correspondent à vos Maps
      _selectedCategory = _fixCategoryId(widget.product!.categoryId);
      _selectedSupplier = _fixSupplierId(widget.product!.supplierId);
    }
  }

  // Méthodes pour corriger les IDs qui ne correspondent pas
  String? _fixCategoryId(String? categoryId) {
    if (categoryId == null) return null;
    // Si l'ID existe dans la map, retournez-le tel quel
    if (categoryMap.containsKey(categoryId)) return categoryId;

    // Sinon, essayez de trouver une correspondance ou retournez null
    // Par exemple, si vous avez "CAT-002" mais que votre produit a "CAT002"
    return categoryMap.keys.firstWhere(
          (key) => key.replaceAll('-', '') == categoryId.replaceAll('-', ''),
      orElse: () => categoryMap.keys.first, // ou retournez null
    );
  }

  String? _fixSupplierId(String? supplierId) {
    if (supplierId == null) return null;
    // Si l'ID existe dans la map, retournez-le tel quel
    if (supplierMap.containsKey(supplierId)) return supplierId;

    // Correction pour "SUPP-001" → "SUP-001"
    if (supplierId == 'SUPP-001') return 'SUP-001';
    if (supplierId == 'SUPP-002') return 'SUP-002';
    if (supplierId == 'SUPP-003') return 'SUP-003';
    if (supplierId == 'SUPP-004') return 'SUP-004';
    if (supplierId == 'SUPP-005') return 'SUP-005';

    // Essayez d'autres correspondances si nécessaire
    return supplierMap.keys.firstWhere(
          (key) => key.replaceAll('-', '') == supplierId.replaceAll('-', ''),
      orElse: () => supplierMap.keys.first, // ou retournez null
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _referenceController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _alertQuantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le produit' : 'Ajouter un produit'),
        actions: isEditing
            ? [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteConfirmation,
          ),
        ]
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Informations de base
              _buildSectionHeader('Informations de base'),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameController,
                label: 'Nom du produit *',
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _referenceController,
                label: 'Référence *',
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La référence est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 3,
              ),

              // Section Prix et Stock
              const SizedBox(height: 24),
              _buildSectionHeader('Prix et Stock'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _priceController,
                      label: 'Prix *',
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      prefixText: '${AppConstants.defaultCurrency} ',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le prix est obligatoire';
                        }
                        if (double.tryParse(value.replaceAll(' ', '')) == null) {
                          return 'Veuillez entrer un nombre valide';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _quantityController,
                      label: 'Quantité *',
                      isInteger: true,
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La quantité est obligatoire';
                        }
                        if (int.tryParse(value.replaceAll(' ', '')) == null) {
                          return 'Veuillez entrer un nombre valide';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _alertQuantityController,
                label: 'Seuil d\'alerte de stock',
                isInteger: true,
                hintText: '5 (valeur par défaut)',
                keyboardType: TextInputType.number,
              ),

              // Section Catégorie et Fournisseur
              const SizedBox(height: 24),
              _buildSectionHeader('Catégorie et Fournisseur'),
              const SizedBox(height: 16),
              _buildDropdown(
                value: _selectedCategory,
                itemsMap: categoryMap,
                hint: 'Sélectionner une catégorie',
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                value: _selectedSupplier,
                itemsMap: supplierMap,
                hint: 'Sélectionner un fournisseur',
                onChanged: (value) {
                  setState(() {
                    _selectedSupplier = value;
                  });
                },
              ),

              // Bouton de soumission
              const SizedBox(height: 32),
              CustomButton(
                text: isEditing ? 'Mettre à jour' : 'Ajouter le produit',
                onPressed: _submitForm,
                isLoading: _isLoading,
                expanded: true,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppConstants.primaryColor,
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required Map<String, String> itemsMap,
    required String hint,
    required Function(String?) onChanged,
  }) {
    // Si la valeur n'existe pas dans la map, utilisez la première valeur ou null
    final effectiveValue = itemsMap.containsKey(value) ? value : null;

    return DropdownButtonFormField<String>(
      value: effectiveValue,
      decoration: InputDecoration(
        labelText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: itemsMap.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value),
        );
      }).toList(),
      onChanged: onChanged,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est obligatoire';
        }
        return null;
      },
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 1));

      try {
        final newProduct = Product(
          id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          reference: _referenceController.text,
          description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
          price: double.parse(_priceController.text.replaceAll(' ', '')),
          quantity: int.parse(_quantityController.text.replaceAll(' ', '')),
          alertQuantity: _alertQuantityController.text.isNotEmpty
              ? int.parse(_alertQuantityController.text.replaceAll(' ', ''))
              : 5,
          categoryId: _selectedCategory,
          supplierId: _selectedSupplier,
          imageUrl: null, // Vous pouvez ajouter un champ pour l'image si besoin
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product != null
                ? 'Produit mis à jour avec succès'
                : 'Produit ajouté avec succès'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, newProduct);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Êtes-vous sûr de vouloir supprimer ce produit ? Cette action est irréversible.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProduct();
              },
              child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Produit supprimé avec succès'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }
}