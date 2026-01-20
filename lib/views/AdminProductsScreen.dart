import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:miniprojet/services/database.dart';
import 'package:miniprojet/widgets/network_image_widget.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _vendeurs = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterCategory = 'all';
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (kDebugMode) {
        print("🔄 Chargement des données depuis Firebase...");
      }
      
      final products = await MongoDatabase.getAllProducts();
      final users = await MongoDatabase.getAllUsers();
      final vendeurs = users.where((u) => u['role'] == 'vendeur').toList();

      final categoriesSet = <String>{};
      for (var product in products) {
        final category = product['category']?.toString();
        if (category != null && category.isNotEmpty) {
          categoriesSet.add(category);
        }
      }
      final categories = categoriesSet.toList()..sort();

      if (kDebugMode) {
        print("📊 Résultats du chargement:");
        print("   - ${products.length} produits");
        print("   - ${categories.length} catégories uniques");
        print("   - ${vendeurs.length} vendeurs");
        if (products.isNotEmpty) {
          print("   - Première catégorie: ${categories.isNotEmpty ? categories.first : 'N/A'}");
          print("   - Exemple produit: ${products.first['title'] ?? 'Sans titre'}");
        }
      }

      setState(() {
        _products = products;
        _vendeurs = vendeurs;
        _categories = categories;
        _isLoading = false;
      });
      
      if (kDebugMode) {
        if (products.isEmpty) {
          print("⚠️ ATTENTION: Aucun produit trouvé dans Firebase!");
          print("   Vérifiez que la collection 'products' contient des données.");
        } else {
          print("✅ Données chargées avec succès!");
        }
      }
    } catch (e, stackTrace) {
      print("✗ Error loading data: $e");
      print("Stack trace: $stackTrace");
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredProducts {
    var filtered = _products;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((product) {
        final title = (product['title'] ?? '').toString().toLowerCase();
        final description = (product['description'] ?? '').toString().toLowerCase();
        final brand = (product['brand'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query) ||
            description.contains(query) ||
            brand.contains(query);
      }).toList();
    }

    if (_filterCategory != 'all') {
      filtered = filtered.where((product) => product['category'] == _filterCategory).toList();
    }

    return filtered;
  }

  void _showAddProductDialog() {
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();
    final brandController = TextEditingController();
    final stockController = TextEditingController();
    final discountController = TextEditingController();
    final imageController = TextEditingController();
    String? selectedVendeurId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          title: const Text('Ajouter un produit', style: TextStyle(color: Color(0xFF000000))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Titre *',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
                    floatingLabelStyle: TextStyle(color: Color(0xFF000000)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF000000)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Prix *',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
                    floatingLabelStyle: TextStyle(color: Color(0xFF000000)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF000000)),
                    ),
                  ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: stockController,
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock *',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
                    floatingLabelStyle: TextStyle(color: Color(0xFF000000)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF000000)),
                    ),
                  ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
                    floatingLabelStyle: TextStyle(color: Color(0xFF000000)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF000000)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Catégorie *',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
                    floatingLabelStyle: TextStyle(color: Color(0xFF000000)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF000000)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: brandController,
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Marque',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
                    floatingLabelStyle: TextStyle(color: Color(0xFF000000)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF000000)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: discountController,
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Remise (%)',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
                    floatingLabelStyle: TextStyle(color: Color(0xFF000000)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF000000)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: imageController,
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'URL de l\'image',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
                    floatingLabelStyle: TextStyle(color: Color(0xFF000000)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF000000)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_vendeurs.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: selectedVendeurId,
                    dropdownColor: const Color(0xFFFFFFFF),
                    style: const TextStyle(color: Color(0xFF000000)),
                    decoration: const InputDecoration(
                      labelText: 'Vendeur',
                      labelStyle: TextStyle(color: Color(0xFF999999)),
                      floatingLabelStyle: TextStyle(color: Color(0xFF000000)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFE5E5E5)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF000000)),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Aucun', style: TextStyle(color: Color(0xFF000000))),
                      ),
                      ..._vendeurs.map((v) => DropdownMenuItem(
                            value: v['_id'],
                            child: Text(
                              v['email'] ?? 'N/A',
                              style: const TextStyle(color: Color(0xFF000000)),
                            ),
                          )),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedVendeurId = value;
                      });
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: Color(0xFF666666))),
            ),
            TextButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty ||
                    priceController.text.trim().isEmpty ||
                    stockController.text.trim().isEmpty ||
                    categoryController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez remplir tous les champs obligatoires'),
                      backgroundColor: Color(0xFF000000),
                    ),
                  );
                  return;
                }

                final vendeur = selectedVendeurId != null
                    ? _vendeurs.firstWhere((v) => v['_id'] == selectedVendeurId)
                    : null;

                final productData = {
                  'title': titleController.text.trim(),
                  'price': double.tryParse(priceController.text.trim()) ?? 0.0,
                  'description': descriptionController.text.trim(),
                  'category': categoryController.text.trim(),
                  'brand': brandController.text.trim(),
                  'stock': int.tryParse(stockController.text.trim()) ?? 0,
                  'discountPercentage': discountController.text.trim().isNotEmpty
                      ? double.tryParse(discountController.text.trim())
                      : null,
                  'image': imageController.text.trim().isNotEmpty
                      ? imageController.text.trim()
                      : null,
                  'vendeurId': vendeur?['_id'],
                  'vendeurEmail': vendeur?['email'],
                  'vendeurName': vendeur != null
                      ? '${vendeur['firstName'] ?? ''} ${vendeur['lastName'] ?? ''}'.trim()
                      : null,
                  'rating': {
                    'rate': 0.0,
                    'count': 0,
                  },
                };

                final success = await MongoDatabase.createProduct(productData);
                if (!context.mounted) return;
                Navigator.pop(context);

                if (success) {
                  _loadData();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Produit créé avec succès'),
                      backgroundColor: Color(0xFF000000),
                    ),
                  );
                } else {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erreur lors de la création'),
                      backgroundColor: Color(0xFF000000),
                    ),
                  );
                }
              },
              child: const Text('Créer', style: TextStyle(color: Color(0xFF000000))),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProductDialog(Map<String, dynamic> product) {
    final titleController = TextEditingController(text: product['title']?.toString() ?? '');
    final priceController = TextEditingController(text: product['price']?.toString() ?? '');
    final descriptionController = TextEditingController(text: product['description']?.toString() ?? '');
    final categoryController = TextEditingController(text: product['category']?.toString() ?? '');
    final brandController = TextEditingController(text: product['brand']?.toString() ?? '');
    final stockController = TextEditingController(text: product['stock']?.toString() ?? '');
    final discountController = TextEditingController(
        text: product['discountPercentage']?.toString() ?? '');
    final imageController = TextEditingController(text: product['image']?.toString() ?? '');
    String? selectedVendeurId = product['vendeurId']?.toString();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          title: const Text('Modifier le produit', style: TextStyle(color: Color(0xFF000000))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Titre *',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
                    floatingLabelStyle: TextStyle(color: Color(0xFF000000)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF000000)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Prix *',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
                    floatingLabelStyle: TextStyle(color: Color(0xFF000000)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF000000)),
                    ),
                  ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: stockController,
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stock *',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
                    floatingLabelStyle: TextStyle(color: Color(0xFF000000)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF000000)),
                    ),
                  ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
                    floatingLabelStyle: TextStyle(color: Color(0xFF000000)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF000000)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Catégorie *',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
                    floatingLabelStyle: TextStyle(color: Color(0xFF000000)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF000000)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: brandController,
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Marque',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
                    floatingLabelStyle: TextStyle(color: Color(0xFF000000)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF000000)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: discountController,
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Remise (%)',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
                    floatingLabelStyle: TextStyle(color: Color(0xFF000000)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF000000)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: imageController,
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'URL de l\'image',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
                    floatingLabelStyle: TextStyle(color: Color(0xFF000000)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF000000)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_vendeurs.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: selectedVendeurId,
                    dropdownColor: const Color(0xFFFFFFFF),
                    style: const TextStyle(color: Color(0xFF000000)),
                    decoration: const InputDecoration(
                      labelText: 'Vendeur',
                      labelStyle: TextStyle(color: Color(0xFF999999)),
                      floatingLabelStyle: TextStyle(color: Color(0xFF000000)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFE5E5E5)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF000000)),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Aucun', style: TextStyle(color: Color(0xFF000000))),
                      ),
                      ..._vendeurs.map((v) => DropdownMenuItem(
                            value: v['_id'],
                            child: Text(
                              v['email'] ?? 'N/A',
                              style: const TextStyle(color: Color(0xFF000000)),
                            ),
                          )),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedVendeurId = value;
                      });
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: Color(0xFF666666))),
            ),
            TextButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty ||
                    priceController.text.trim().isEmpty ||
                    stockController.text.trim().isEmpty ||
                    categoryController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez remplir tous les champs obligatoires'),
                      backgroundColor: Color(0xFF000000),
                    ),
                  );
                  return;
                }

                final vendeur = selectedVendeurId != null
                    ? _vendeurs.firstWhere((v) => v['_id'] == selectedVendeurId)
                    : null;

                final updates = {
                  'title': titleController.text.trim(),
                  'price': double.tryParse(priceController.text.trim()) ?? 0.0,
                  'description': descriptionController.text.trim(),
                  'category': categoryController.text.trim(),
                  'brand': brandController.text.trim(),
                  'stock': int.tryParse(stockController.text.trim()) ?? 0,
                  'discountPercentage': discountController.text.trim().isNotEmpty
                      ? double.tryParse(discountController.text.trim())
                      : null,
                  'image': imageController.text.trim().isNotEmpty
                      ? imageController.text.trim()
                      : null,
                  'vendeurId': vendeur?['_id'],
                  'vendeurEmail': vendeur?['email'],
                  'vendeurName': vendeur != null
                      ? '${vendeur['firstName'] ?? ''} ${vendeur['lastName'] ?? ''}'.trim()
                      : null,
                };

                final success = await MongoDatabase.updateProduct(product['_id'], updates);
                if (!context.mounted) return;
                Navigator.pop(context);

                if (success) {
                  _loadData();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Produit modifié avec succès'),
                      backgroundColor: Color(0xFF000000),
                    ),
                  );
                } else {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erreur lors de la modification'),
                      backgroundColor: Color(0xFF000000),
                    ),
                  );
                }
              },
              child: const Text('Enregistrer', style: TextStyle(color: Color(0xFF000000))),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteProductDialog(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('Supprimer le produit', style: TextStyle(color: Color(0xFF000000))),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${product['title']}" ?\nCette action est irréversible.',
          style: const TextStyle(color: Color(0xFF666666)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Color(0xFF666666))),
          ),
          TextButton(
            onPressed: () async {
              final success = await MongoDatabase.deleteProduct(product['_id']);
              if (!context.mounted) return;
              Navigator.pop(context);

              if (success) {
                _loadData();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Produit supprimé avec succès'),
                    backgroundColor: Color(0xFF000000),
                  ),
                );
              } else {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erreur lors de la suppression'),
                    backgroundColor: Color(0xFF000000),
                  ),
                );
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Color(0xFF000000))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color(0xFFFFFFFF),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                color: const Color(0xFFFFFFFF),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_products.length} PRODUIT(S) | ${_categories.length} CATÉGORIE(S)',
                          style: const TextStyle(
                            color: Color(0xFF000000),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        if (_products.isEmpty)
                          TextButton.icon(
                            onPressed: () async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Synchronisation des produits en cours...'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              await MongoDatabase.syncProductsFromFakeStore();
                              _loadData();
                            },
                            icon: const Icon(Icons.sync, size: 16, color: Color(0xFF000000)),
                            label: const Text('Synchroniser', style: TextStyle(fontSize: 12, color: Color(0xFF000000))),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF000000),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      style: const TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un produit...',
                        hintStyle: const TextStyle(color: Color(0xFF999999)),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF666666), size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Color(0xFF000000)),
                                onPressed: () {
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFFFFFFFF),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0),
                          borderSide: const BorderSide(color: Color(0xFF000000), width: 1.5),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    if (_categories.isNotEmpty)
                      SizedBox(
                        height: 44,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          children: [
                            FilterChip(
                              label: const Text('Toutes', style: TextStyle(color: Color(0xFF000000), fontSize: 12)),
                              selected: _filterCategory == 'all',
                              selectedColor: const Color(0xFF000000),
                              checkmarkColor: const Color(0xFFFFFFFF),
                              backgroundColor: const Color(0xFFFFFFFF),
                              side: BorderSide(
                                color: _filterCategory == 'all' 
                                    ? const Color(0xFF000000) 
                                    : const Color(0xFFE5E5E5),
                                width: 1,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              onSelected: (_) {
                                setState(() {
                                  _filterCategory = 'all';
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                            ..._categories.map((category) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(
                                      category,
                                      style: const TextStyle(color: Color(0xFF000000), fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    selected: _filterCategory == category,
                                    selectedColor: const Color(0xFF000000),
                                    checkmarkColor: const Color(0xFFFFFFFF),
                                    backgroundColor: const Color(0xFFFFFFFF),
                                    side: BorderSide(
                                      color: _filterCategory == category 
                                          ? const Color(0xFF000000) 
                                          : const Color(0xFFE5E5E5),
                                      width: 1,
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    onSelected: (_) {
                                      setState(() {
                                        _filterCategory = category;
                                      });
                                    },
                                  ),
                                )),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF000000)),
                        ),
                      )
                    : _filteredProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.inventory_2_outlined, size: 64, color: Color(0xFF999999)),
                                const SizedBox(height: 16),
                                Text(
                                  _products.isEmpty 
                                      ? 'Aucun produit dans Firebase'
                                      : 'Aucun produit correspondant aux filtres',
                                  style: const TextStyle(color: Color(0xFF000000)),
                                ),
                                if (_products.isEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Total: ${_products.length} produit(s)',
                                    style: const TextStyle(color: Color(0xFF666666), fontSize: 12),
                                  ),
                                ] else ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '${_filteredProducts.length} sur ${_products.length} produit(s)',
                                    style: const TextStyle(color: Color(0xFF666666), fontSize: 12),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            color: const Color(0xFF000000),
                            child: GridView.builder(
                              padding: const EdgeInsets.all(24),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.42,
                                crossAxisSpacing: 24,
                                mainAxisSpacing: 24,
                              ),
                              itemCount: _filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = _filteredProducts[index];
                                final finalPrice = product['discountPercentage'] != null &&
                                        product['price'] != null
                                    ? ((product['price'] as num) *
                                        (1 - (product['discountPercentage'] as num) / 100))
                                    : product['price'];

                                final rating = (product['rating'] as Map<String, dynamic>?) ?? {};
                                
                                return Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFFFF),
                                    border: Border.all(
                                      color: const Color(0xFF000000),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF000000).withValues(alpha: 0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: double.infinity,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFF5F5F5),
                                              ),
                                              child: (product['image'] != null && 
                                                      product['image'].toString().trim().isNotEmpty &&
                                                      (product['image'].toString().startsWith('http://') || 
                                                       product['image'].toString().startsWith('https://')))
                                                  ? NetworkImageWidget(
                                                      imageUrl: product['image'].toString().trim(),
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      fit: BoxFit.contain,
                                                    )
                                                  : Container(
                                                      color: const Color(0xFFF5F5F5),
                                                      child: const Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(
                                                            Icons.shopping_bag,
                                                            size: 48,
                                                            color: Color(0xFF999999),
                                                          ),
                                                          SizedBox(height: 8),
                                                          Text(
                                                            'Aucune image',
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              color: Color(0xFF999999),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                            ),
                                            if (product['discountPercentage'] != null)
                                              Positioned(
                                                top: 8,
                                                left: 8,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 3,
                                                  ),
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xFF000000),
                                                  ),
                                                  child: Text(
                                                    '-${product['discountPercentage']}%',
                                                    style: const TextStyle(
                                                      color: Color(0xFFFFFFFF),
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            if (rating['rate'] != null)
                                              Positioned(
                                                bottom: 8,
                                                left: 8,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 5,
                                                    vertical: 3,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFFFFFFF),
                                                    border: Border.all(
                                                      color: const Color(0xFF000000),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                        Icons.star,
                                                        size: 10,
                                                        color: Color(0xFF000000),
                                                      ),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        '${rating['rate']}',
                                                        style: const TextStyle(
                                                          color: Color(0xFF000000),
                                                          fontSize: 9,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (product['brand'] != null)
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 2),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 4, vertical: 1),
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFF000000),
                                                    ),
                                                    child: Text(
                                                      product['brand']!.toUpperCase(),
                                                      style: const TextStyle(
                                                        fontSize: 6,
                                                        color: Color(0xFFFFFFFF),
                                                        fontWeight: FontWeight.bold,
                                                        letterSpacing: 0.8,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              Flexible(
                                                child: Text(
                                                  product['title'] ?? '',
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF000000),
                                                    height: 1.1,
                                                    letterSpacing: 0.1,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Flexible(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        if (product['discountPercentage'] != null)
                                                          Padding(
                                                            padding: const EdgeInsets.only(bottom: 0),
                                                            child: Text(
                                                              '${product['price']} \$',
                                                              style: const TextStyle(
                                                                fontSize: 8,
                                                                color: Color(0xFF999999),
                                                                decoration: TextDecoration.lineThrough,
                                                              ),
                                                            ),
                                                          ),
                                                        Text(
                                                          '${finalPrice?.toStringAsFixed(2) ?? '-'} \$',
                                                          style: const TextStyle(
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.bold,
                                                            color: Color(0xFF000000),
                                                            letterSpacing: 0.2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (product['stock'] != null)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 2, vertical: 1),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF000000).withValues(alpha: 0.1),
                                                        border: Border.all(
                                                          color: const Color(0xFF000000),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          const Icon(
                                                            Icons.check_circle,
                                                            size: 6,
                                                            color: Color(0xFF000000),
                                                          ),
                                                          const SizedBox(width: 1),
                                                          Text(
                                                            '${product['stock']}',
                                                            style: const TextStyle(
                                                              fontSize: 6,
                                                              fontWeight: FontWeight.bold,
                                                              color: Color(0xFF000000),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 36,
                                                    height: 36,
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF000000),
                                                      border: Border.all(
                                                        color: const Color(0xFF000000),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        onTap: () => _showEditProductDialog(product),
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.edit,
                                                            size: 18,
                                                            color: Color(0xFFFFFFFF),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    width: 36,
                                                    height: 36,
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFFFFFFF),
                                                      border: Border.all(
                                                        color: const Color(0xFF000000),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        onTap: () => _showDeleteProductDialog(product),
                                                        child: const Center(
                                                          child: Icon(
                                                            Icons.delete,
                                                            size: 18,
                                                            color: Color(0xFF000000),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            onPressed: _showAddProductDialog,
            backgroundColor: const Color(0xFF000000),
            foregroundColor: const Color(0xFFFFFFFF),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
