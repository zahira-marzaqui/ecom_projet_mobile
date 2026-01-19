import 'package:flutter/material.dart';
import 'package:miniprojet/services/FavoritesService.dart';
import 'package:miniprojet/services/ShoppingCartService.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritesService = FavoritesService();
    final cartService = ShoppingCartService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Favoris'),
        backgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: const Color(0xFF000000),
      ),
      body: Container(
        color: const Color(0xFFFFFFFF),
        child: ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: favoritesService.favorites,
          builder: (context, favorites, child) {
            if (favorites.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 100,
                      color: const Color(0xFF999999),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Aucun favori',
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xFF000000),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ajoutez des produits à vos favoris',
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

            return GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.44,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final product = favorites[index];
                final price = product['price'] as num? ?? 0;
                final discount = product['discountPercentage'] as num? ?? 0;
                final finalPrice = price * (1 - discount / 100);
                final imageUrl = product['image'] as String?;
                final title = product['title'] ?? 'Sans titre';

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
                    children: [
                      // Image avec bouton favori
                      Expanded(
                        flex: 4,
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF5F5F5),
                              ),
                              child: imageUrl != null && imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
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
                            // Bouton retirer des favoris
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFFFFF),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF000000),
                                    width: 1,
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.favorite, color: Color(0xFF000000), size: 20),
                                  onPressed: () {
                                    favoritesService.removeFromFavorites(product);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('$title retiré des favoris'),
                                        duration: const Duration(seconds: 2),
                                        backgroundColor: const Color(0xFF000000),
                                      ),
                                    );
                                  },
                                  iconSize: 20,
                                  padding: const EdgeInsets.all(8),
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ),
                            // Badge de réduction
                            if (discount > 0)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF000000),
                                  ),
                                  child: Text(
                                    '-${discount.toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      color: Color(0xFFFFFFFF),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Informations du produit
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF000000),
                                  height: 1.15,
                                  letterSpacing: 0.15,
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
                                        if (discount > 0)
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 0),
                                            child: Text(
                                              '${price.toStringAsFixed(2)} \$',
                                              style: const TextStyle(
                                                fontSize: 9,
                                                color: Color(0xFF999999),
                                                decoration: TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ),
                                        Text(
                                          '${finalPrice.toStringAsFixed(2)} \$',
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
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Bouton Ajouter au panier
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              cartService.addToCart(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('$title ajouté au panier!'),
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
            );
          },
        ),
      ),
    );
  }
}
