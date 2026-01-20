import 'package:flutter/material.dart';
import 'package:miniprojet/services/database.dart';

class AdminUsersScreen extends StatefulWidget {
  final VoidCallback? onUserChanged;

  const AdminUsersScreen({super.key, this.onUserChanged});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterRole = 'all';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    final users = await MongoDatabase.getAllUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
    widget.onUserChanged?.call();
  }

  List<Map<String, dynamic>> get _filteredUsers {
    var filtered = _users;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        final email = (user['email'] ?? '').toString().toLowerCase();
        final username = (user['username'] ?? '').toString().toLowerCase();
        final firstName = (user['firstName'] ?? '').toString().toLowerCase();
        final lastName = (user['lastName'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return email.contains(query) ||
            username.contains(query) ||
            firstName.contains(query) ||
            lastName.contains(query);
      }).toList();
    }

    if (_filterRole != 'all') {
      filtered = filtered.where((user) => user['role'] == _filterRole).toList();
    }

    return filtered;
  }

  void _showAddUserDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final usernameController = TextEditingController();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    String selectedRole = 'client';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          title: const Text('Ajouter un utilisateur', style: TextStyle(color: Color(0xFF000000))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Color(0xFF000000)),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
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
                  controller: passwordController,
                  style: const TextStyle(color: Color(0xFF000000)),
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
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
                  controller: usernameController,
                  style: const TextStyle(color: Color(0xFF000000)),
                  decoration: const InputDecoration(
                    labelText: 'Nom d\'utilisateur',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
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
                  controller: firstNameController,
                  style: const TextStyle(color: Color(0xFF000000)),
                  decoration: const InputDecoration(
                    labelText: 'Prénom',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
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
                  controller: lastNameController,
                  style: const TextStyle(color: Color(0xFF000000)),
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF000000)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  dropdownColor: const Color(0xFFFFFFFF),
                  style: const TextStyle(color: Color(0xFF000000)),
                  decoration: const InputDecoration(
                    labelText: 'Rôle',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF000000)),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'client', child: Text('Client', style: TextStyle(color: Color(0xFF000000)))),
                    DropdownMenuItem(value: 'vendeur', child: Text('Vendeur', style: TextStyle(color: Color(0xFF000000)))),
                    DropdownMenuItem(value: 'admin', child: Text('Admin', style: TextStyle(color: Color(0xFF000000)))),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedRole = value!;
                    });
                  },
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
                if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Veuillez remplir tous les champs obligatoires'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final userData = {
                  'email': emailController.text.trim(),
                  'password': passwordController.text,
                  'username': usernameController.text.trim().isEmpty
                      ? emailController.text.trim().split('@')[0]
                      : usernameController.text.trim(),
                  'firstName': firstNameController.text.trim(),
                  'lastName': lastNameController.text.trim(),
                  'role': selectedRole,
                };

                final success = await MongoDatabase.createUser(userData);
                if (!context.mounted) return;
                Navigator.pop(context);

                if (success) {
                  _loadUsers();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Utilisateur créé avec succès'),
                      backgroundColor: Color(0xFF000000),
                    ),
                  );
                } else {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erreur: Email déjà utilisé'),
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

  void _showEditUserDialog(Map<String, dynamic> user) {
    final emailController = TextEditingController(text: user['email'] ?? '');
    final usernameController = TextEditingController(text: user['username'] ?? '');
    final firstNameController = TextEditingController(text: user['firstName'] ?? '');
    final lastNameController = TextEditingController(text: user['lastName'] ?? '');
    String selectedRole = user['role'] ?? 'client';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFFFFFFF),
          title: const Text('Modifier l\'utilisateur', style: TextStyle(color: Color(0xFF000000))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Color(0xFF000000)),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
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
                  controller: usernameController,
                  style: const TextStyle(color: Color(0xFF000000)),
                  decoration: const InputDecoration(
                    labelText: 'Nom d\'utilisateur',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
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
                  controller: firstNameController,
                  style: const TextStyle(color: Color(0xFF000000)),
                  decoration: const InputDecoration(
                    labelText: 'Prénom',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
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
                  controller: lastNameController,
                  style: const TextStyle(color: Color(0xFF000000)),
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF000000)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  dropdownColor: const Color(0xFFFFFFFF),
                  style: const TextStyle(color: Color(0xFF000000)),
                  decoration: const InputDecoration(
                    labelText: 'Rôle',
                    labelStyle: TextStyle(color: Color(0xFF999999)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE5E5E5)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF000000)),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'client', child: Text('Client', style: TextStyle(color: Color(0xFF000000)))),
                    DropdownMenuItem(value: 'vendeur', child: Text('Vendeur', style: TextStyle(color: Color(0xFF000000)))),
                    DropdownMenuItem(value: 'admin', child: Text('Admin', style: TextStyle(color: Color(0xFF000000)))),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedRole = value!;
                    });
                  },
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
                final updates = {
                  'email': emailController.text.trim(),
                  'username': usernameController.text.trim(),
                  'firstName': firstNameController.text.trim(),
                  'lastName': lastNameController.text.trim(),
                  'role': selectedRole,
                };

                final success = await MongoDatabase.updateUser(user['_id'], updates);
                if (!context.mounted) return;
                Navigator.pop(context);

                if (success) {
                  _loadUsers();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Utilisateur modifié avec succès'),
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

  void _showDeleteUserDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text('Supprimer l\'utilisateur', style: TextStyle(color: Color(0xFF000000))),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${user['email']}" ?\nCette action est irréversible.',
          style: const TextStyle(color: Color(0xFF666666)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Color(0xFF666666))),
          ),
          TextButton(
            onPressed: () async {
              final success = await MongoDatabase.deleteUser(user['_id']);
              if (!context.mounted) return;
              Navigator.pop(context);

              if (success) {
                _loadUsers();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Utilisateur supprimé avec succès'),
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

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'vendeur':
        return Colors.orange;
      case 'client':
        return Colors.blue;
      default:
        return Colors.grey;
    }
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
                const SizedBox(height: 8),
                TextField(
                      style: const TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un utilisateur...',
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
                const SizedBox(height: 16),
                Row(
                      children: [
                        Expanded(
                          child: SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: 'all', label: Text('Tous')),
                              ButtonSegment(value: 'client', label: Text('Clients')),
                              ButtonSegment(value: 'vendeur', label: Text('Vendeurs')),
                              ButtonSegment(value: 'admin', label: Text('Admins')),
                            ],
                            selected: {_filterRole},
                            onSelectionChanged: (Set<String> newSelection) {
                              setState(() {
                                _filterRole = newSelection.first;
                              });
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return const Color(0xFF000000);
                                }
                                return const Color(0xFFFFFFFF);
                              }),
                              foregroundColor: WidgetStateProperty.resolveWith((states) {
                                if (states.contains(WidgetState.selected)) {
                                  return const Color(0xFFFFFFFF);
                                }
                                return const Color(0xFF000000);
                              }),
                              side: WidgetStateProperty.resolveWith((states) {
                                return const BorderSide(
                                  color: Color(0xFF000000),
                                  width: 1,
                                );
                              }),
                            ),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
                    : _filteredUsers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.people_outline, size: 64, color: Color(0xFF999999)),
                                const SizedBox(height: 16),
                                const Text(
                                  'Aucun utilisateur trouvé',
                                  style: TextStyle(color: Color(0xFF000000)),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadUsers,
                            color: const Color(0xFF000000),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(24),
                              itemCount: _filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = _filteredUsers[index];
                                return Card(
                                  color: const Color(0xFFFFFFFF),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                    side: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
                                  ),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFF000000).withValues(alpha: 0.1),
                                      child: const Icon(
                                        Icons.person,
                                        color: Color(0xFF000000),
                                      ),
                                    ),
                                    title: Text(
                                      user['email'] ?? 'N/A',
                                      style: const TextStyle(
                                        color: Color(0xFF000000),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (user['username'] != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              '@${user['username']}',
                                              style: const TextStyle(color: Color(0xFF666666), fontSize: 12),
                                            ),
                                          ),
                                        const SizedBox(height: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF000000),
                                          ),
                                          child: Text(
                                            (user['role'] ?? 'client').toUpperCase(),
                                            style: const TextStyle(
                                              color: Color(0xFFFFFFFF),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
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
                                              onTap: () => _showEditUserDialog(user),
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
                                              onTap: () => _showDeleteUserDialog(user),
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
            onPressed: _showAddUserDialog,
            backgroundColor: const Color(0xFF000000),
            foregroundColor: const Color(0xFFFFFFFF),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
