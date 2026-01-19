import 'package:flutter/material.dart';
import 'package:miniprojet/services/database.dart';

class VendeurProfileScreen extends StatelessWidget {
  const VendeurProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = MongoDatabase.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: const Color(0xFF000000),
      ),
      body: Container(
        color: const Color(0xFFFFFFFF),
        child: currentUser == null
            ? const Center(
                child: Text(
                  'Aucun utilisateur connecté',
                  style: TextStyle(color: Color(0xFF000000)),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête du profil
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF000000).withValues(alpha: 0.1),
                              border: Border.all(
                                color: const Color(0xFF000000),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Color(0xFF000000),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '${currentUser['firstName'] ?? ''} ${currentUser['lastName'] ?? ''}'.trim().isEmpty
                                ? currentUser['username'] ?? currentUser['email'] ?? 'Vendeur'
                                : '${currentUser['firstName'] ?? ''} ${currentUser['lastName'] ?? ''}'.trim(),
                            style: const TextStyle(
                              color: Color(0xFF000000),
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: const BoxDecoration(
                              color: Color(0xFF000000),
                            ),
                            child: const Text(
                              'VENDEUR',
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Informations du profil
                    _buildSectionTitle('Informations personnelles'),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      icon: Icons.email,
                      label: 'Email',
                      value: currentUser['email'] ?? 'N/A',
                    ),
                    const SizedBox(height: 12),
                    if (currentUser['username'] != null)
                      _buildInfoCard(
                        icon: Icons.person_outline,
                        label: 'Nom d\'utilisateur',
                        value: currentUser['username'] ?? 'N/A',
                      ),
                    if (currentUser['username'] != null) const SizedBox(height: 12),
                    if (currentUser['firstName'] != null || currentUser['lastName'] != null)
                      _buildInfoCard(
                        icon: Icons.badge,
                        label: 'Nom complet',
                        value: '${currentUser['firstName'] ?? ''} ${currentUser['lastName'] ?? ''}'.trim(),
                      ),
                    if (currentUser['firstName'] != null || currentUser['lastName'] != null)
                      const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.shield,
                      label: 'Rôle',
                      value: 'VENDEUR',
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF666666),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      color: const Color(0xFFFFFFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
              child: Icon(icon, color: const Color(0xFF000000), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF000000),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
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
