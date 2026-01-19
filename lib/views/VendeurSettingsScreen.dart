import 'package:flutter/material.dart';
import 'package:miniprojet/services/database.dart';

class VendeurSettingsScreen extends StatefulWidget {
  const VendeurSettingsScreen({super.key});

  @override
  State<VendeurSettingsScreen> createState() => _VendeurSettingsScreenState();
}

class _VendeurSettingsScreenState extends State<VendeurSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  String _selectedLanguage = 'Français';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: const Color(0xFF000000),
      ),
      body: Container(
        color: const Color(0xFFFFFFFF),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Section Compte
            _buildSectionTitle('Compte'),
            const SizedBox(height: 8),
            _buildSettingsCard(
              children: [
                _buildSettingsTile(
                  icon: Icons.person,
                  title: 'Modifier le profil',
                  subtitle: 'Gérer vos informations personnelles',
                  onTap: () {
                    Navigator.of(context).pushNamed('/vendeur-profile');
                  },
                ),
                const Divider(color: Color(0xFFE5E5E5)),
                _buildSettingsTile(
                  icon: Icons.lock,
                  title: 'Changer le mot de passe',
                  subtitle: 'Mettre à jour votre mot de passe',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fonctionnalité à venir'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Color(0xFF000000),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Section Préférences
            _buildSectionTitle('Préférences'),
            const SizedBox(height: 8),
            _buildSettingsCard(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications, color: Color(0xFF000000)),
                  title: const Text('Notifications', style: TextStyle(color: Color(0xFF000000))),
                  subtitle: const Text('Recevoir des notifications', style: TextStyle(color: Color(0xFF666666))),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  activeColor: const Color(0xFF000000),
                ),
                const Divider(color: Color(0xFFE5E5E5)),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode, color: Color(0xFF000000)),
                  title: const Text('Mode sombre', style: TextStyle(color: Color(0xFF000000))),
                  subtitle: const Text('Activer le thème sombre', style: TextStyle(color: Color(0xFF666666))),
                  value: _darkModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _darkModeEnabled = value;
                    });
                  },
                  activeColor: const Color(0xFF000000),
                ),
                const Divider(color: Color(0xFFE5E5E5)),
                ListTile(
                  leading: const Icon(Icons.language, color: Color(0xFF000000)),
                  title: const Text('Langue', style: TextStyle(color: Color(0xFF000000))),
                  subtitle: Text(_selectedLanguage, style: const TextStyle(color: Color(0xFF666666))),
                  trailing: const Icon(Icons.chevron_right, color: Color(0xFF000000)),
                  onTap: () {
                    _showLanguageDialog(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Section Application
            _buildSectionTitle('Application'),
            const SizedBox(height: 8),
            _buildSettingsCard(
              children: [
                _buildSettingsTile(
                  icon: Icons.info,
                  title: 'À propos',
                  subtitle: 'Version 1.0.0',
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
                const Divider(color: Color(0xFFE5E5E5)),
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: 'Aide et support',
                  subtitle: 'Obtenir de l\'aide',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fonctionnalité à venir'),
                        duration: Duration(seconds: 2),
                        backgroundColor: Color(0xFF000000),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Bouton de déconnexion
            ElevatedButton.icon(
              onPressed: () {
                MongoDatabase.logout();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('DÉCONNEXION'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF000000),
                foregroundColor: const Color(0xFFFFFFFF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
            ),
          ],
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

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Card(
      color: const Color(0xFFFFFFFF),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? const Color(0xFF000000)),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? const Color(0xFF000000)),
      ),
      subtitle: Text(subtitle, style: const TextStyle(color: Color(0xFF666666))),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF000000)),
      onTap: onTap,
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('Choisir la langue', style: TextStyle(color: Color(0xFF000000))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Français', style: TextStyle(color: Color(0xFF000000))),
              value: 'Français',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
              },
              activeColor: const Color(0xFF000000),
            ),
            RadioListTile<String>(
              title: const Text('English', style: TextStyle(color: Color(0xFF000000))),
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
              },
              activeColor: const Color(0xFF000000),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('À propos', style: TextStyle(color: Color(0xFF000000))),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mini Projet E-commerce', style: TextStyle(color: Color(0xFF000000), fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Version 1.0.0', style: TextStyle(color: Color(0xFF666666))),
            SizedBox(height: 16),
            Text('Application de commerce électronique développée avec Flutter et MongoDB.', style: TextStyle(color: Color(0xFF666666))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer', style: TextStyle(color: Color(0xFF000000))),
          ),
        ],
      ),
    );
  }
}
