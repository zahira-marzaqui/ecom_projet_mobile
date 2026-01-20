import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:miniprojet/services/database.dart';
import 'dart:math';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var categories = await MongoDatabase.getAllCategories();
      
      if (categories.isEmpty) {
        if (kDebugMode) {
          print("ℹ️ Aucune catégorie dans la collection, extraction depuis les produits...");
        }
        final products = await MongoDatabase.getAllProducts();
        final categoriesSet = <String>{};
        
        for (var product in products) {
          final category = product['category']?.toString();
          if (category != null && category.isNotEmpty) {
            categoriesSet.add(category);
          }
        }
        
        categories = categoriesSet.map((name) => {
          'name': name,
          'description': 'Catégorie extraite des produits',
        }).toList();
        
        if (kDebugMode) {
          print("✓ ${categories.length} catégories extraites depuis ${products.length} produits");
        }
      }
      
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
      
      if (kDebugMode) {
        print("✓ Total: ${categories.length} catégories à afficher");
      }
    } catch (e) {
      print("✗ Error loading categories: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredCategories {
    if (_searchQuery.isEmpty) return _categories;
    
    return _categories.where((category) {
      final name = (category['name'] ?? '').toString().toLowerCase();
      final description = (category['description'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || description.contains(query);
    }).toList();
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('Ajouter une catégorie', style: TextStyle(color: Color(0xFF000000))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nom de la catégorie *',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez entrer un nom de catégorie'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final categoryData = {
                'name': nameController.text.trim(),
                'description': descriptionController.text.trim(),
              };

              final success = await MongoDatabase.createCategory(categoryData);
              if (!context.mounted) return;
              Navigator.pop(context);

              if (success) {
                _loadCategories();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Catégorie créée avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erreur: Catégorie déjà existante'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Créer', style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(Map<String, dynamic> category) {
    final nameController = TextEditingController(text: category['name'] ?? '');
    final descriptionController = TextEditingController(text: category['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('Modifier la catégorie', style: TextStyle(color: Color(0xFF000000))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nom de la catégorie *',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez entrer un nom de catégorie'),
                      backgroundColor: Color(0xFF000000),
                    ),
                  );
                  return;
                }

              final updates = {
                'name': nameController.text.trim(),
                'description': descriptionController.text.trim(),
              };

              final success = await MongoDatabase.updateCategory(category['_id'], updates);
              if (!context.mounted) return;
              Navigator.pop(context);

              if (success) {
                _loadCategories();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Catégorie modifiée avec succès'),
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
    );
  }

  List<Color> _getCategoryColors(String categoryName) {
    final colorsList = [
      [Color(0xFF667EEA), Color(0xFF764BA2)], // Violet
      [Color(0xFFF093FB), Color(0xFFF5576C)], // Rose
      [Color(0xFF4FACFE), Color(0xFF00F2FE)], // Bleu
      [Color(0xFF43E97B), Color(0xFF38F9D7)], // Vert
      [Color(0xFFFA709A), Color(0xFFFEE140)], // Rose-jaune
      [Color(0xFF30CFD0), Color(0xFF330867)], // Cyan-violet
      [Color(0xFFA8EDEA), Color(0xFFFED6E3)], // Turquoise-rose
      [Color(0xFFFF6B6B), Color(0xFFEE5A6F)], // Rouge
      [Color(0xFFFF8A80), Color(0xFFFF6B9D)], // Orange-rose
      [Color(0xFFC471ED), Color(0xFFF64F59)], // Violet-rouge
      [Color(0xFF4ECDC4), Color(0xFF44A08D)], // Turquoise
      [Color(0xFF96DEDA), Color(0xFF50C9C3)], // Aqua
      [Color(0xFFF09819), Color(0xFFEDDE5D)], // Orange-jaune
      [Color(0xFFFF9A9E), Color(0xFFFECFEF)], // Rose clair
      [Color(0xFFA18CD1), Color(0xFFFBC2EB)], // Violet-rose
      [Color(0xFFFFD89B), Color(0xFF19547B)], // Jaune-bleu
      [Color(0xFF89F7FE), Color(0xFF66A6FF)], // Bleu clair
      [Color(0xFF2C3E50), Color(0xFF34495E)], // Gris foncé
      [Color(0xFFE74C3C), Color(0xFFC0392B)], // Rouge foncé
      [Color(0xFFFFD700), Color(0xFFFFA500)], // Or-orange
    ];
    
    final hash = categoryName.hashCode;
    final index = hash.abs() % colorsList.length;
    return colorsList[index];
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    
    if (name.contains('watch')) return Icons.watch;
    if (name.contains('shoe') || name.contains('sneaker')) return Icons.shopping_bag;
    if (name.contains('jewel') || name.contains('diamond')) return Icons.diamond;
    if (name.contains('dress') || name.contains('woman')) return Icons.checkroom;
    if (name.contains('bag') || name.contains('handbag')) return Icons.shopping_bag;
    if (name.contains('vehicle') || name.contains('car') || name.contains('auto')) return Icons.directions_car;
    if (name.contains('top') || name.contains('shirt')) return Icons.checkroom;
    if (name.contains('phone') || name.contains('smartphone')) return Icons.smartphone;
    if (name.contains('laptop') || name.contains('computer')) return Icons.laptop;
    if (name.contains('fragrance') || name.contains('perfume')) return Icons.spa;
    if (name.contains('skincare') || name.contains('beauty')) return Icons.face;
    if (name.contains('grocery') || name.contains('food')) return Icons.shopping_basket;
    if (name.contains('home') || name.contains('decoration')) return Icons.home;
    if (name.contains('furniture') || name.contains('chair')) return Icons.chair;
    if (name.contains('motorcycle') || name.contains('bike')) return Icons.two_wheeler;
    if (name.contains('lighting') || name.contains('light')) return Icons.lightbulb;
    if (name.contains('sunglass')) return Icons.dark_mode;
    
    return Icons.category;
  }

  void _showDeleteCategoryDialog(Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('Supprimer la catégorie', style: TextStyle(color: Color(0xFF000000))),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${category['name']}" ?\nCette action est irréversible.',
          style: const TextStyle(color: Color(0xFF666666)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Color(0xFF666666))),
          ),
          TextButton(
            onPressed: () async {
              final success = await MongoDatabase.deleteCategory(category['_id']);
              if (!context.mounted) return;
              Navigator.pop(context);

              if (success) {
                _loadCategories();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Catégorie supprimée avec succès'),
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
                    Text(
                      '${_categories.length} CATÉGORIE(S) DANS FIREBASE',
                      style: const TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      style: const TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Rechercher une catégorie...',
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
                    : _filteredCategories.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.category_outlined, size: 64, color: Color(0xFF999999)),
                                const SizedBox(height: 16),
                                const Text(
                                  'Aucune catégorie trouvée',
                                  style: TextStyle(color: Color(0xFF000000)),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Total: ${_categories.length} catégorie(s)',
                                  style: const TextStyle(color: Color(0xFF666666), fontSize: 12),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadCategories,
                            color: const Color(0xFF000000),
                            child: GridView.builder(
                              padding: const EdgeInsets.all(24),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 24,
                                mainAxisSpacing: 24,
                              ),
                              itemCount: _filteredCategories.length,
                              itemBuilder: (context, index) {
                                final category = _filteredCategories[index];
                                final categoryName = category['name']?.toString() ?? 'Sans nom';
                                
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF000000),
                                            border: Border.all(
                                              color: const Color(0xFF000000),
                                              width: 1,
                                            ),
                                          ),
                                          child: Icon(
                                            _getCategoryIcon(categoryName),
                                            color: const Color(0xFFFFFFFF),
                                            size: 32,
                                          ),
                                        ),
                                        const Spacer(),
                                        Flexible(
                                          child: Text(
                                            categoryName.toUpperCase(),
                                            style: const TextStyle(
                                              color: Color(0xFF000000),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1.5,
                                              height: 1.3,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        if (category['description'] != null &&
                                            category['description'].toString().isNotEmpty)
                                          Flexible(
                                            child: Text(
                                              category['description'],
                                              style: const TextStyle(
                                                color: Color(0xFF666666),
                                                fontSize: 10,
                                                height: 1.2,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        else
                                          const Text(
                                            'Catégorie extraite',
                                            style: TextStyle(
                                              color: Color(0xFF999999),
                                              fontSize: 10,
                                            ),
                                          ),
                                        const SizedBox(height: 12),
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
                                                  onTap: () => _showEditCategoryDialog(category),
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
                                                  onTap: () => _showDeleteCategoryDialog(category),
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
            onPressed: _showAddCategoryDialog,
            backgroundColor: const Color(0xFF000000),
            foregroundColor: const Color(0xFFFFFFFF),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
