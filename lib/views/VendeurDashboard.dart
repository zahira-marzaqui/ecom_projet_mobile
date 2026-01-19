import 'package:flutter/material.dart';
import 'package:miniprojet/services/database.dart';

class VendeurDashboard extends StatefulWidget {
  const VendeurDashboard({super.key});

  @override
  State<VendeurDashboard> createState() => _VendeurDashboardState();
}

class _VendeurDashboardState extends State<VendeurDashboard> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _products = [];
  String? _vendeurName;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _deleteProduct(Map<String, dynamic> product) async {
    if (!MongoDatabase.isConnected) {
      return;
    }

    final productId = product['_id'];
    if (productId == null) {
      return;
    }

    final success = await MongoDatabase.deleteProduct(productId);
    if (success) {
      _loadProducts(); // Recharger la liste
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product['title']} supprimé avec succès'),
            backgroundColor: const Color(0xFF000000),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la suppression'),
            backgroundColor: Color(0xFF000000),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text(
          'Supprimer le produit',
          style: TextStyle(color: Color(0xFF000000)),
        ),
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
            onPressed: () {
              Navigator.pop(context);
              _deleteProduct(product);
            },
            child: const Text('Supprimer', style: TextStyle(color: Color(0xFF000000))),
          ),
        ],
      ),
    );
  }

  Future<void> _loadProducts() async {
    if (!MongoDatabase.isConnected || MongoDatabase.currentUser == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final vendeurEmail = MongoDatabase.currentUser!['email']?.toString();
    if (vendeurEmail == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final firstName = MongoDatabase.currentUser!['firstName']?.toString() ?? '';
    final lastName = MongoDatabase.currentUser!['lastName']?.toString() ?? '';
    _vendeurName = '$firstName $lastName'.trim();
    if (_vendeurName!.isEmpty) {
      _vendeurName = MongoDatabase.currentUser!['username']?.toString() ?? 'Vendeur';
    }

    final products = await MongoDatabase.getProductsByVendeurEmail(vendeurEmail);
    
    products.sort((a, b) {
      final aDate = a['createdAt'];
      final bDate = b['createdAt'];
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return (bDate as Comparable).compareTo(aDate);
    });

    setState(() {
      _products = products;
      _isLoading = false;
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
                          : currentUser['username'] ?? currentUser['email'] ?? 'Vendeur')
                      : 'Vendeur',
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
              Navigator.of(context).pushNamed('/vendeur-profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFF000000)),
            title: const Text('Paramètres', style: TextStyle(color: Color(0xFF000000))),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/vendeur-settings');
            },
          ),
          const Divider(color: Color(0xFFE5E5E5)),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'ACTIONS',
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle, color: Color(0xFF000000)),
            title: const Text('Ajouter un produit', style: TextStyle(color: Color(0xFF000000))),
            onTap: () async {
              Navigator.pop(context);
              final result = await Navigator.of(context).pushNamed('/vendeur-add-product');
              if (result == true) {
                _loadProducts();
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFF000000)),
            title: const Text('Accueil', style: TextStyle(color: Color(0xFF000000))),
            onTap: () {
              Navigator.pop(context);
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
        title: Text(_vendeurName != null ? 'Dashboard - $_vendeurName' : 'Vendeur Dashboard'),
        backgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: const Color(0xFF000000),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF000000)),
            tooltip: 'Ajouter un produit',
            onPressed: () async {
              final result = await Navigator.of(context).pushNamed('/vendeur-add-product');
              if (result == true) {
                _loadProducts();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF000000)),
            tooltip: 'Rafraîchir les produits',
            onPressed: _loadProducts,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF000000)),
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
            : !MongoDatabase.isConnected || MongoDatabase.currentUser == null
                ? const Center(
                    child: Text(
                      'Base de données non connectée.\nLes produits ne peuvent pas être chargés.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF000000)),
                    ),
                  )
                : _products.isEmpty
                    ? RefreshIndicator(
                        onRefresh: _loadProducts,
                        color: const Color(0xFF000000),
                        child: const SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: 400,
                            child: Center(
                              child: Text(
                                'Aucun produit assigné.\nTirez vers le bas pour rafraîchir.',
                                style: TextStyle(color: Color(0xFF000000)),
                              ),
                            ),
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProducts,
                        color: const Color(0xFF000000),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF),
                                  border: Border.all(
                                    color: const Color(0xFF000000),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF000000).withValues(alpha: 0.1),
                                        border: Border.all(
                                          color: const Color(0xFF000000),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Icon(Icons.inventory_2, color: Color(0xFF000000), size: 24),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(
                                      '${_products.length} PRODUIT(S)',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF000000),
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: GridView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(24),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.42,
                                  crossAxisSpacing: 24,
                                  mainAxisSpacing: 24,
                                ),
                                itemCount: _products.length,
                                itemBuilder: (context, index) {
                                  final p = _products[index];
                                  final rating = (p['rating'] as Map<String, dynamic>?) ?? {};
                                  final finalPrice = p['discountPercentage'] != null && p['price'] != null
                                      ? ((p['price'] as num) * (1 - (p['discountPercentage'] as num) / 100))
                                      : p['price'];

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
                                                child: (p['image'] != null && 
                                                        p['image'].toString().trim().isNotEmpty &&
                                                        (p['image'].toString().startsWith('http://') || 
                                                         p['image'].toString().startsWith('https://')))
                                                    ? Image.network(
                                                        p['image'].toString().trim(),
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
                                                          child: const Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Icon(
                                                                Icons.image_not_supported,
                                                                size: 48,
                                                                color: Color(0xFF999999),
                                                              ),
                                                              SizedBox(height: 8),
                                                              Text(
                                                                'Image non disponible',
                                                                style: TextStyle(
                                                                  fontSize: 10,
                                                                  color: Color(0xFF999999),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
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
                                              if (p['discountPercentage'] != null)
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
                                                      '-${p['discountPercentage']}%',
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
                                                if (p['brand'] != null)
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom: 2),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 4, vertical: 1),
                                                      decoration: const BoxDecoration(
                                                        color: Color(0xFF000000),
                                                      ),
                                                      child: Text(
                                                        p['brand']!.toUpperCase(),
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
                                                    p['title'] ?? '',
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
                                                          if (p['discountPercentage'] != null)
                                                            Padding(
                                                              padding: const EdgeInsets.only(bottom: 0),
                                                              child: Text(
                                                                '${p['price']} \$',
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
                                                    if (p['stock'] != null)
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
                                                              '${p['stock']}',
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
                                                          onTap: () async {
                                                            final result = await Navigator.of(context).pushNamed(
                                                              '/vendeur-edit-product',
                                                              arguments: p,
                                                            );
                                                            if (result == true) {
                                                              _loadProducts();
                                                            }
                                                          },
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
                                                          onTap: () => _showDeleteDialog(context, p),
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
                          ],
                        ),
                      ),
      ),
    );
  }
}
