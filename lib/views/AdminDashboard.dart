import 'package:flutter/material.dart';
import 'package:miniprojet/services/database.dart';
import 'package:miniprojet/views/AdminUsersScreen.dart';
import 'package:miniprojet/views/AdminCategoriesScreen.dart';
import 'package:miniprojet/views/AdminProductsScreen.dart';
import 'package:miniprojet/views/AdminProfileScreen.dart';
import 'package:miniprojet/views/AdminSettingsScreen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  Map<String, int> _statistics = {};
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoadingStats = true;
    });
    final stats = await MongoDatabase.getAdminStatistics();
    setState(() {
      _statistics = stats;
      _isLoadingStats = false;
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
                    Icons.admin_panel_settings,
                    size: 30,
                    color: Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  currentUser != null
                      ? (currentUser['firstName'] != null || currentUser['lastName'] != null
                          ? '${currentUser['firstName'] ?? ''} ${currentUser['lastName'] ?? ''}'.trim()
                          : currentUser['username'] ?? currentUser['email'] ?? 'Admin')
                      : 'Admin',
                  style: const TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentUser?['email'] ?? 'admin@admin.com',
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
              Navigator.of(context).pushNamed('/admin-profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFF000000)),
            title: const Text('Paramètres', style: TextStyle(color: Color(0xFF000000))),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamed('/admin-settings');
            },
          ),
          const Divider(color: Color(0xFFE5E5E5)),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'GESTION',
              style: TextStyle(
                color: Color(0xFF666666),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Color(0xFF000000)),
            title: const Text('Utilisateurs', style: TextStyle(color: Color(0xFF000000))),
            selected: _selectedIndex == 0,
            selectedTileColor: const Color(0xFF000000).withValues(alpha: 0.1),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 0;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.category, color: Color(0xFF000000)),
            title: const Text('Catégories', style: TextStyle(color: Color(0xFF000000))),
            selected: _selectedIndex == 1,
            selectedTileColor: const Color(0xFF000000).withValues(alpha: 0.1),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 1;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2, color: Color(0xFF000000)),
            title: const Text('Produits', style: TextStyle(color: Color(0xFF000000))),
            selected: _selectedIndex == 2,
            selectedTileColor: const Color(0xFF000000).withValues(alpha: 0.1),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _selectedIndex = 2;
              });
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

  Widget _buildStatisticsCard() {
    if (_isLoadingStats) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF000000)),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.35,
        children: [
          _buildStatCard(
            icon: Icons.people,
            label: 'Utilisateurs',
            value: '${_statistics['totalUsers'] ?? 0}',
            color: Colors.blueAccent,
          ),
          _buildStatCard(
            icon: Icons.inventory_2,
            label: 'Produits',
            value: '${_statistics['totalProducts'] ?? 0}',
            color: Colors.green,
          ),
          _buildStatCard(
            icon: Icons.category,
            label: 'Catégories',
            value: '${_statistics['totalCategories'] ?? 0}',
            color: Colors.orange,
          ),
          _buildStatCard(
            icon: Icons.shopping_bag,
            label: 'Clients',
            value: '${_statistics['totalClients'] ?? 0}',
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      color: const Color(0xFFFFFFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: const BorderSide(color: Color(0xFF000000), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF000000).withValues(alpha: 0.1),
                border: Border.all(
                  color: const Color(0xFF000000),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, color: const Color(0xFF000000), size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF000000),
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                height: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
                height: 1.0,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return AdminUsersScreen(onUserChanged: _loadStatistics);
      case 1:
        return AdminCategoriesScreen();
      case 2:
        return AdminProductsScreen();
      default:
        return AdminUsersScreen(onUserChanged: _loadStatistics);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = MongoDatabase.currentUser;

    return Scaffold(
      drawer: _buildDrawer(context, currentUser),
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: const Color(0xFF000000),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF000000)),
            tooltip: 'Rafraîchir',
            onPressed: _loadStatistics,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF000000)),
            tooltip: 'Déconnexion',
            onPressed: () {
              MongoDatabase.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFFFFFF),
        child: _selectedIndex == 0
            ? Column(
                children: [
                  _buildStatisticsCard(),
                  Expanded(
                    child: _buildCurrentScreen(),
                  ),
                ],
              )
            : _buildCurrentScreen(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFFFFFFF),
        selectedItemColor: const Color(0xFF000000),
        unselectedItemColor: const Color(0xFF666666),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Utilisateurs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Catégories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Produits',
          ),
        ],
      ),
    );
  }
}
