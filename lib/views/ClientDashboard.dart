import 'package:flutter/material.dart';
import 'package:miniprojet/services/database.dart';
import 'package:miniprojet/services/ShoppingCartService.dart';
import 'package:miniprojet/services/FavoritesService.dart';

class ClientDashboard extends StatefulWidget {
  final String? initialCategory;
  
  const ClientDashboard({super.key, this.initialCategory});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  final ShoppingCartService _cartService = ShoppingCartService();
  final FavoritesService _favoritesService = FavoritesService();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  List<String> _categories = [];
  String? _selectedCategory;
  String _searchQuery = '';
  bool _isSearching = false;
  
  final int _itemsPerPage = 12;
  int _currentPage = 0;
  
  @override
  void initState() {
    super.initState();
    _loadProducts();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null) {
        if (args is Map && args['search'] != null) {
          final searchQuery = args['search'] as String;
          _searchController.text = searchQuery;
          _searchQuery = searchQuery;
          _performSearch(searchQuery);
        } else if (args is String) {
          _selectedCategory = args;
          _filterByCategory(args);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    if (!MongoDatabase.isConnected) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final snapshot = await MongoDatabase.db.collection(MongoDatabase.productCollectionName).get();
    final products = snapshot.docs.map((doc) {
      final data = doc.data();
      data['_id'] = doc.id;
      return data;
    }).toList();

    products.sort((a, b) {
      final aDate = a['createdAt'];
      final bDate = b['createdAt'];
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return (bDate as Comparable).compareTo(aDate);
    });

    final categoriesSet = <String>{};
    for (var product in products) {
      final category = product['category']?.toString();
      if (category != null && category.isNotEmpty) {
        categoriesSet.add(category);
      }
    }
    final categories = categoriesSet.toList()..sort();

    setState(() {
      _allProducts = products;
      _categories = categories;
      _selectedCategory = widget.initialCategory;
      if (widget.initialCategory != null) {
        _filteredProducts = _allProducts
            .where((p) => p['category']?.toString() == widget.initialCategory)
            .toList();
      } else {
        _filteredProducts = products;
      }
      _currentPage = 0;
      _isLoading = false;
    });
    
    if (_searchQuery.isNotEmpty) {
      _performSearch(_searchQuery);
    }
  }

  void _filterByCategory(String? category) {
    setState(() {
      _selectedCategory = category;
      _searchQuery = '';
      _searchController.clear();
      _isSearching = false;
      if (category == null) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts
            .where((p) => p['category']?.toString() == category)
            .toList();
      }
      _currentPage = 0;
    });
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _searchQuery = '';
        _isSearching = false;
        _selectedCategory = null;
        _filteredProducts = _allProducts;
        _currentPage = 0;
      });
      return;
    }

    _favoritesService.addToSearchHistory(query);

    setState(() {
      _searchQuery = query.trim();
      _isSearching = true;
      _selectedCategory = null;
      
      _filteredProducts = _allProducts.where((product) {
        final title = (product['title'] ?? '').toString().toLowerCase();
        final description = (product['description'] ?? '').toString().toLowerCase();
        final category = (product['category'] ?? '').toString().toLowerCase();
        final brand = (product['brand'] ?? '').toString().toLowerCase();
        final searchLower = query.toLowerCase();
        
        return title.contains(searchLower) ||
            description.contains(searchLower) ||
            category.contains(searchLower) ||
            brand.contains(searchLower);
      }).toList();
      
      _filteredProducts.sort((a, b) {
        final aDate = a['createdAt'];
        final bDate = b['createdAt'];
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return (bDate as Comparable).compareTo(aDate);
      });
      
      _currentPage = 0;
    });
  }

  List<Map<String, dynamic>> get _paginatedProducts {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, _filteredProducts.length);
    return _filteredProducts.sublist(startIndex, endIndex);
  }

  int get _totalPages => (_filteredProducts.length / _itemsPerPage).ceil();

  void _goToPage(int page) {
    setState(() {
      _currentPage = page.clamp(0, _totalPages - 1);
    });
  }

  Widget _buildDrawer(BuildContext context, Map<String, dynamic>? currentUser) {
    return Drawer(
      backgroundColor: const Color(0xFFFFFFFF),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF000000).withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 30,
                    color: Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  currentUser != null
                      ? (currentUser['firstName'] != null || currentUser['lastName'] != null
                          ? '${currentUser['firstName'] ?? ''} ${currentUser['lastName'] ?? ''}'.trim()
                          : currentUser['username'] ?? currentUser['email'] ?? 'Utilisateur')
                      : 'Utilisateur',
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentUser?['email'] ?? 'email@example.com',
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF000000)),
            title: const Text('Mon Profil', style: TextStyle(color: Color(0xFF000000))),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFF000000)),
            title: const Text('Paramètres', style: TextStyle(color: Color(0xFF000000))),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/settings');
            },
          ),
          const Divider(color: Color(0xFFE5E5E5)),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Liens rapides',
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart, color: Color(0xFF000000)),
            title: const Text('Mon Panier', style: TextStyle(color: Color(0xFF000000))),
            trailing: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: _cartService.cart,
              builder: (context, cartItems, child) {
                return cartItems.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF000000),
                        ),
                        child: Text(
                          '${cartItems.length}',
                          style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/cart');
            },
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFF000000)),
            title: const Text('Accueil', style: TextStyle(color: Color(0xFF000000))),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.category, color: Color(0xFF000000)),
            title: const Text('Catégories', style: TextStyle(color: Color(0xFF000000))),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/categories');
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: Color(0xFF000000)),
            title: const Text('Favoris', style: TextStyle(color: Color(0xFF000000))),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/favorites');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Color(0xFF000000)),
            title: const Text('Historique', style: TextStyle(color: Color(0xFF000000))),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/search-history');
            },
          ),
          const Divider(color: Color(0xFFE5E5E5)),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFF000000)),
            title: const Text('Déconnexion', style: TextStyle(color: Color(0xFF000000))),
            onTap: () {
              Navigator.pop(context);
              MongoDatabase.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = MongoDatabase.currentUser;
    
    return Scaffold(
      drawer: _buildDrawer(context, currentUser),
      appBar: AppBar(
        title: const Text('Boutique'),
        backgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: const Color(0xFF000000),
        actions: [
          ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: _cartService.cart,
            builder: (context, cartItems, child) {
              return Badge(
                label: Text(cartItems.length.toString()),
                isLabelVisible: cartItems.isNotEmpty,
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  tooltip: 'Voir le panier',
                  onPressed: () {
                    Navigator.of(context).pushNamed('/cart');
                  },
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir les produits',
            onPressed: _loadProducts,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              MongoDatabase.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFFFFFF),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF000000)),
                ),
              )
            : !MongoDatabase.isConnected
                ? const Center(
                    child: Text(
                      'Base de données non connectée.\nLes produits ne peuvent pas être chargés.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF000000)),
                    ),
                  )
                : _allProducts.isEmpty
                    ? RefreshIndicator(
                        onRefresh: _loadProducts,
                        color: const Color(0xFF000000),
                        child: const SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: 400,
                            child: Center(
                              child: Text(
                                'Aucun produit disponible.\nTirez vers le bas pour rafraîchir.',
                                style: TextStyle(color: Color(0xFF000000)),
      ),
                            ),
                          ),
                        ),
                      )
                    : Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          color: const Color(0xFFFFFFFF),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFFFF),
                                    border: Border.all(
                                      color: const Color(0xFF000000),
                                      width: 1,
                                    ),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    style: const TextStyle(color: Color(0xFF000000)),
                                    decoration: InputDecoration(
                                      hintText: 'Rechercher un produit...',
                                      hintStyle: const TextStyle(color: Color(0xFF999999)),
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        color: Color(0xFF000000),
                                      ),
                                      suffixIcon: _searchController.text.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(
                                                Icons.clear,
                                                color: Color(0xFF000000),
                                              ),
                                              onPressed: () {
                                                _searchController.clear();
                                                _performSearch('');
                                              },
                                            )
                                          : null,
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                    onSubmitted: (value) {
                                      _performSearch(value);
                                    },
                                    onChanged: (value) {
                                      if (value.isEmpty) {
                                        _performSearch('');
                                      }
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.history),
                                color: const Color(0xFF000000),
                                tooltip: 'Historique de recherche',
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/search-history');
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 60,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          color: const Color(0xFFFFFFFF),
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: FilterChip(
                                  label: Text(
                                    'Tous',
                                    style: TextStyle(
                                      color: _selectedCategory == null && !_isSearching
                                          ? const Color(0xFFFFFFFF)
                                          : const Color(0xFF000000),
                                    ),
                                  ),
                                  selected: _selectedCategory == null && !_isSearching,
                                  selectedColor: const Color(0xFF000000),
                                  checkmarkColor: const Color(0xFFFFFFFF),
                                  backgroundColor: _selectedCategory == null && !_isSearching
                                      ? const Color(0xFF000000)
                                      : const Color(0xFFFFFFFF),
                                  side: BorderSide(
                                    color: _selectedCategory == null && !_isSearching
                                        ? const Color(0xFF000000)
                                        : const Color(0xFFE5E5E5),
                                    width: 1,
                                  ),
                                  onSelected: (_) {
                                    _searchController.clear();
                                    _filterByCategory(null);
                                  },
                                  avatar: _selectedCategory == null && !_isSearching
                                      ? const Icon(Icons.check, size: 18, color: Color(0xFFFFFFFF))
                                      : null,
                                ),
                              ),
                              ..._categories.map((category) => Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: FilterChip(
                                      label: Text(
                                        category,
                                        style: TextStyle(
                                          color: _selectedCategory == category
                                              ? const Color(0xFFFFFFFF)
                                              : const Color(0xFF000000),
                                        ),
                                      ),
                                      selected: _selectedCategory == category,
                                      selectedColor: const Color(0xFF000000),
                                      checkmarkColor: const Color(0xFFFFFFFF),
                                      backgroundColor: _selectedCategory == category
                                          ? const Color(0xFF000000)
                                          : const Color(0xFFFFFFFF),
                                      side: BorderSide(
                                        color: _selectedCategory == category
                                            ? const Color(0xFF000000)
                                            : const Color(0xFFE5E5E5),
                                        width: 1,
                                      ),
                                      onSelected: (_) => _filterByCategory(category),
                                      avatar: _selectedCategory == category
                                          ? const Icon(Icons.check, size: 18, color: Color(0xFFFFFFFF))
                                          : null,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        Container(
                          color: const Color(0xFFFFFFFF),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          child: Row(
                            children: [
                              Text(
                                '${_filteredProducts.length} produit(s)',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF000000),
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              if (_isSearching)
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Chip(
                                    backgroundColor: const Color(0xFF000000),
                                    label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.search, size: 14, color: Color(0xFFFFFFFF)),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            'Recherche: $_searchQuery',
                                            style: const TextStyle(fontSize: 12, color: Color(0xFFFFFFFF)),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onDeleted: () {
                                      _searchController.clear();
                                      _performSearch('');
                                    },
                                    deleteIcon: const Icon(Icons.close, size: 18, color: Color(0xFFFFFFFF)),
                                  ),
                                )
                              else if (_selectedCategory != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: Chip(
                                    backgroundColor: const Color(0xFF000000),
                                    label: Text(
                                      'Catégorie: $_selectedCategory',
                                      style: const TextStyle(fontSize: 12, color: Color(0xFFFFFFFF)),
                                    ),
                                    onDeleted: () => _filterByCategory(null),
                                    deleteIcon: const Icon(Icons.close, size: 18, color: Color(0xFFFFFFFF)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: const Color(0xFFFFFFFF),
                            child: RefreshIndicator(
                              onRefresh: _loadProducts,
                              color: const Color(0xFF000000),
                              child: GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(24),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.44,
                                crossAxisSpacing: 24,
                                mainAxisSpacing: 24,
                              ),
                              itemCount: _paginatedProducts.length,
                              itemBuilder: (context, index) {
                                final p = _paginatedProducts[index];
                                final rating = (p['rating'] as Map<String, dynamic>?) ?? {};
                                final finalPrice = p['discountPercentage'] != null && p['price'] != null
                                    ? ((p['price'] as num) * (1 - (p['discountPercentage'] as num) / 100))
                                    : p['price'];

                                return Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFFFF),
                                    border: Border.all(
                                      color: const Color(0xFFE5E5E5),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF000000).withValues(alpha: 0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
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
                                              child: p['image'] != null
                                                  ? Image.network(
                                                      p['image'],
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      fit: BoxFit.contain,
                                                      loadingBuilder: (context, child, loadingProgress) {
                                                        if (loadingProgress == null) return child;
                                                        return Container(
                                                          color: const Color(0xFFF5F5F5),
                                                          child: const Center(
                                                            child: CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                                Color(0xFF000000),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      errorBuilder: (_, __, ___) => Container(
                                                        color: const Color(0xFFF5F5F5),
                                                        child: const Icon(
                                                          Icons.image_not_supported,
                                                          size: 40,
                                                          color: Color(0xFF999999),
                                                        ),
                                                      ),
                                                    )
                                                  : const Icon(
                                                      Icons.shopping_bag,
                                                      size: 40,
                                                      color: Color(0xFF999999),
                                                    ),
                                            ),
                                            if (p['discountPercentage'] != null)
                                              Positioned(
                                                top: 12,
                                                right: 12,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 8, vertical: 4),
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xFF000000),
                                                  ),
                                                  child: Text(
                                                    '-${p['discountPercentage']}%',
                                                    style: const TextStyle(
                                                      color: Color(0xFFFFFFFF),
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            Positioned(
                                              bottom: 12,
                                              right: 12,
                                              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                                                valueListenable: _favoritesService.favorites,
                                                builder: (context, favorites, child) {
                                                  final isFavorite = _favoritesService.isFavorite(p);
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFFFFFFF),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: const Color(0xFF000000),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: IconButton(
                                                      icon: Icon(
                                                        isFavorite ? Icons.favorite : Icons.favorite_border,
                                                        color: const Color(0xFF000000),
                                                        size: 20,
                                                      ),
                                                      onPressed: () {
                                                        if (isFavorite) {
                                                          _favoritesService.removeFromFavorites(p);
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text('${p['title']} retiré des favoris'),
                                                              duration: const Duration(seconds: 2),
                                                              backgroundColor: const Color(0xFF000000),
                                                            ),
                                                          );
                                                        } else {
                                                          _favoritesService.addToFavorites(p);
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text('${p['title']} ajouté aux favoris'),
                                                              duration: const Duration(seconds: 2),
                                                              backgroundColor: const Color(0xFF000000),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      padding: const EdgeInsets.all(8),
                                                      constraints: const BoxConstraints(),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            if (rating['rate'] != null)
                                              Positioned(
                                                top: 12,
                                                left: 12,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 6, vertical: 4),
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
                                                        size: 12,
                                                        color: Color(0xFF000000),
                                                      ),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        '${rating['rate']}',
                                                        style: const TextStyle(
                                                          color: Color(0xFF000000),
                                                          fontSize: 10,
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
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (p['brand'] != null)
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 3),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 5, vertical: 1),
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFF000000),
                                                    ),
                                                    child: Text(
                                                      p['brand']!.toUpperCase(),
                                                      style: const TextStyle(
                                                        fontSize: 7,
                                                        color: Color(0xFFFFFFFF),
                                                        fontWeight: FontWeight.bold,
                                                        letterSpacing: 1.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              Flexible(
                                                child: Text(
                                                  p['title'] ?? '',
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF000000),
                                                    height: 1.1,
                                                    letterSpacing: 0.15,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Flexible(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        if (p['discountPercentage'] != null)
                                                          Padding(
                                                            padding: const EdgeInsets.only(bottom: 0),
                                                            child: Text(
                                                              '${p['price']} \$',
                                                              style: const TextStyle(
                                                                fontSize: 9,
                                                                color: Color(0xFF999999),
                                                                decoration: TextDecoration.lineThrough,
                                                              ),
                                                            ),
                                                          ),
                                                        Text(
                                                          '${finalPrice?.toStringAsFixed(2) ?? '-'} \$',
                                                          style: const TextStyle(
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.bold,
                                                            color: Color(0xFF000000),
                                                            letterSpacing: 0.2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  if (p['stock'] != null)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 3, vertical: 1),
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
                                                            size: 7,
                                                            color: Color(0xFF000000),
                                                          ),
                                                          const SizedBox(width: 1),
                                                          Text(
                                                            '${p['stock']}',
                                                            style: const TextStyle(
                                                              fontSize: 7,
                                                              fontWeight: FontWeight.bold,
                                                              color: Color(0xFF000000),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              _cartService.addToCart(p);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('${p['title']} ajouté au panier!'),
                                                  duration: const Duration(seconds: 2),
                                                  backgroundColor: const Color(0xFF000000),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF000000),
                                              foregroundColor: const Color(0xFFFFFFFF),
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              minimumSize: const Size(0, 38),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(0),
                                              ),
                                            ),
                                            child: const Text(
                                              'AJOUTER AU PANIER',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.8,
                                              ),
                                            ),
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
                        ),
                        if (_totalPages > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFFFFF),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.chevron_left, color: Color(0xFF000000)),
                                  onPressed: _currentPage > 0
                                      ? () => _goToPage(_currentPage - 1)
                                      : null,
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFFFFF),
                                    side: const BorderSide(color: Color(0xFF000000), width: 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ...List.generate(
                                  _totalPages < 3 ? _totalPages : 3,
                                  (i) {
                                    int pageIndex;
                                    if (_currentPage < 2) {
                                      pageIndex = i;
                                    } else if (_currentPage >= _totalPages - 2) {
                                      pageIndex = _totalPages - 3 + i;
                                    } else {
                                      pageIndex = _currentPage - 1 + i;
                                    }
                                    
                                    pageIndex = pageIndex.clamp(0, _totalPages - 1);
                                    
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: TextButton(
                                        onPressed: () => _goToPage(pageIndex),
                                        style: TextButton.styleFrom(
                                          backgroundColor: _currentPage == pageIndex
                                              ? const Color(0xFF000000)
                                              : const Color(0xFFFFFFFF),
                                          minimumSize: const Size(40, 40),
                                          padding: EdgeInsets.zero,
                                          side: BorderSide(
                                            color: const Color(0xFF000000),
                                            width: _currentPage == pageIndex ? 0 : 1,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(0),
                                          ),
                                        ),
                                        child: Text(
                                          '${pageIndex + 1}',
                                          style: TextStyle(
                                            color: _currentPage == pageIndex
                                                ? const Color(0xFFFFFFFF)
                                                : const Color(0xFF000000),
                                            fontSize: 14,
                                            fontWeight: _currentPage == pageIndex
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(Icons.chevron_right, color: Color(0xFF000000)),
                                  onPressed: _currentPage < _totalPages - 1
                                      ? () => _goToPage(_currentPage + 1)
                                      : null,
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFFFFF),
                                    side: const BorderSide(color: Color(0xFF000000), width: 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
      ),
    );
  }
}
