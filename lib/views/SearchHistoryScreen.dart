import 'package:flutter/material.dart';
import 'package:miniprojet/services/FavoritesService.dart';

class SearchHistoryScreen extends StatelessWidget {
  const SearchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesService = FavoritesService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique de recherche'),
        backgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: const Color(0xFF000000),
        actions: [
          ValueListenableBuilder<List<String>>(
            valueListenable: favoritesService.searchHistory,
            builder: (context, history, child) {
              if (history.isEmpty) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xFF000000)),
                tooltip: 'Vider l\'historique',
                onPressed: () {
                  _showClearHistoryDialog(context, favoritesService);
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFFFFFFF),
        child: ValueListenableBuilder<List<String>>(
          valueListenable: favoritesService.searchHistory,
          builder: (context, history, child) {
            if (history.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 100,
                      color: const Color(0xFF999999),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Aucun historique',
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xFF000000),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Vos recherches récentes apparaîtront ici',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                        letterSpacing: 0.25,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final query = history[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: const Color(0xFFFFFFFF),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                    side: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF000000).withValues(alpha: 0.1),
                        border: Border.all(
                          color: const Color(0xFF000000),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.search,
                        color: Color(0xFF000000),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      query,
                      style: const TextStyle(
                        color: Color(0xFF000000),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF000000)),
                      onPressed: () {
                        favoritesService.removeFromSearchHistory(query);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('"$query" supprimé de l\'historique'),
                            duration: const Duration(seconds: 2),
                            backgroundColor: const Color(0xFF000000),
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      // Naviguer vers ClientDashboard avec la recherche
                      Navigator.of(context).pushReplacementNamed(
                        '/client',
                        arguments: {'search': query},
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showClearHistoryDialog(
    BuildContext context,
    FavoritesService favoritesService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        title: const Text(
          'Vider l\'historique',
          style: TextStyle(color: Color(0xFF000000)),
        ),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer tout l\'historique de recherche ?',
          style: TextStyle(color: Color(0xFF666666)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Color(0xFF666666))),
          ),
          TextButton(
            onPressed: () {
              favoritesService.clearSearchHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Historique vidé'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Color(0xFF000000),
                ),
              );
            },
            child: const Text('Vider', style: TextStyle(color: Color(0xFF000000))),
          ),
        ],
      ),
    );
  }
}
