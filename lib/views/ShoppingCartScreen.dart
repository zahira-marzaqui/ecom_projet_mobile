import 'package:flutter/material.dart';
import 'package:miniprojet/services/ShoppingCartService.dart';
import 'package:miniprojet/widgets/network_image_widget.dart';

class ShoppingCartScreen extends StatelessWidget {
  const ShoppingCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartService = ShoppingCartService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Panier'),
        backgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: const Color(0xFF000000),
      ),
      body: Container(
        color: const Color(0xFFFFFFFF),
        child: ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: cartService.cart,
          builder: (context, cartItems, child) {
            if (cartItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 100,
                      color: const Color(0xFF999999),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Votre panier est vide',
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xFF000000),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ajoutez des produits pour commencer',
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

            // Calculer le prix total
            final totalPrice = cartService.getTotalPrice();

            return Column(
              children: [
                // Liste des produits
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final product = cartItems[index];
                      final price = product['price'] as num? ?? 0;
                      final discount = product['discountPercentage'] as num? ?? 0;
                      final finalPrice = price * (1 - discount / 100);
                      final imageUrl = product['image'] as String?;
                      final title = product['title'] ?? 'Sans titre';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        color: const Color(0xFFFFFFFF),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                          side: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image du produit
                              ClipRRect(
                                child: imageUrl != null && imageUrl.isNotEmpty
                                    ? NetworkImageWidget(
                                        imageUrl: imageUrl,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 100,
                                        height: 100,
                                        color: const Color(0xFFF5F5F5),
                                        child: const Icon(
                                          Icons.shopping_bag,
                                          color: Color(0xFF999999),
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              // Informations du produit
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        color: Color(0xFF000000),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    if (discount > 0)
                                      Text(
                                        '${price.toStringAsFixed(2)} \$',
                                        style: const TextStyle(
                                          color: Color(0xFF999999),
                                          fontSize: 12,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                    Text(
                                      '${finalPrice.toStringAsFixed(2)} \$',
                                      style: const TextStyle(
                                        color: Color(0xFF000000),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    if (discount > 0)
                                      Container(
                                        margin: const EdgeInsets.only(top: 8),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
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
                                  ],
                                ),
                              ),
                              // Bouton supprimer
                              IconButton(
                                icon: const Icon(Icons.close),
                                color: const Color(0xFF000000),
                                onPressed: () {
                                  cartService.removeFromCart(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('$title supprimé du panier'),
                                      duration: const Duration(seconds: 2),
                                      backgroundColor: const Color(0xFF000000),
                                    ),
                                  );
                                },
                                tooltip: 'Supprimer du panier',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Résumé du panier
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    border: Border(
                      top: BorderSide(color: Color(0xFFE5E5E5), width: 1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SUBTOTAL (${cartItems.length} ITEMS)',
                            style: const TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            '${totalPrice.toStringAsFixed(2)} \$',
                            style: const TextStyle(
                              color: Color(0xFF000000),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFFE5E5E5)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL',
                            style: TextStyle(
                              color: Color(0xFF000000),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            '${totalPrice.toStringAsFixed(2)} \$',
                            style: const TextStyle(
                              color: Color(0xFF000000),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implémenter la fonctionnalité de commande
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fonctionnalité de commande à venir'),
                                duration: Duration(seconds: 2),
                                backgroundColor: Color(0xFF000000),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF000000),
                            foregroundColor: const Color(0xFFFFFFFF),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                          child: const Text(
                            'PROCEED TO CHECKOUT',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
