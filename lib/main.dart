import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:miniprojet/services/database.dart';
import 'package:miniprojet/views/ClientDashboard.dart';
import 'package:miniprojet/views/LoginScreen.dart';
import 'package:miniprojet/views/ShoppingCartScreen.dart';
import 'package:miniprojet/views/SingUpScreen.dart';
import 'package:miniprojet/views/VendeurDashboard.dart';
import 'package:miniprojet/views/VendeurAddProductScreen.dart';
import 'package:miniprojet/views/VendeurEditProductScreen.dart';
import 'package:miniprojet/views/VendeurProfileScreen.dart';
import 'package:miniprojet/views/VendeurSettingsScreen.dart';
import 'package:miniprojet/views/AdminDashboard.dart';
import 'package:miniprojet/views/AdminProfileScreen.dart';
import 'package:miniprojet/views/AdminSettingsScreen.dart';
import 'package:miniprojet/views/ProfileScreen.dart';
import 'package:miniprojet/views/SettingsScreen.dart';
import 'package:miniprojet/views/CategoriesScreen.dart';
import 'package:miniprojet/views/FavoritesScreen.dart';
import 'package:miniprojet/views/SearchHistoryScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await MongoDatabase.connect();
    await MongoDatabase.createDefaultUsers();
    await MongoDatabase.syncProductsFromFakeStore();
    if (kDebugMode) {
      print("✓ Application prête avec MongoDB connecté");
    }
  } catch (e) {
    MongoDatabase.isConnected = false;
    if (kDebugMode) {
      print("⚠️ Erreur de connexion MongoDB: $e");
      print(
          "⚠️ L'application démarre quand même, mais les fonctionnalités de base de données ne seront pas disponibles.");
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF000000), // Noir pour les boutons principaux
          onPrimary: Color(0xFFFFFFFF), // Blanc pour le texte sur boutons noirs
          secondary: Color(0xFF000000), // Noir pour les éléments secondaires
          surface: Color(0xFFFFFFFF), // Blanc pour les surfaces
          onSurface: Color(0xFF000000), // Noir pour le texte principal
          error: Color(0xFF000000),
          onError: Color(0xFFFFFFFF),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: Color(0xFF000000),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF000000),
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Color(0xFF000000),
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            color: Color(0xFF000000),
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          displaySmall: TextStyle(
            color: Color(0xFF000000),
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
          headlineMedium: TextStyle(
            color: Color(0xFF000000),
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
          titleLarge: TextStyle(
            color: Color(0xFF000000),
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
          ),
          titleMedium: TextStyle(
            color: Color(0xFF000000),
            fontSize: 18,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.15,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF000000),
            fontSize: 16,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.5,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF000000),
            fontSize: 14,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.25,
          ),
          bodySmall: TextStyle(
            color: Color(0xFF666666),
            fontSize: 12,
            fontWeight: FontWeight.normal,
            letterSpacing: 0.4,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF000000),
            foregroundColor: const Color(0xFFFFFFFF),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF000000),
            side: const BorderSide(color: Color(0xFF000000), width: 1),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFFFFFF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
            side: const BorderSide(color: Color(0xFFE5E5E5), width: 1),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFFFFFF),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0),
            borderSide: const BorderSide(color: Color(0xFF000000), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0),
            borderSide: const BorderSide(color: Color(0xFF000000), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0),
            borderSide: const BorderSide(color: Color(0xFF000000), width: 2),
          ),
          labelStyle: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 14,
          ),
          hintStyle: const TextStyle(
            color: Color(0xFF999999),
            fontSize: 14,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE5E5E5),
          thickness: 1,
          space: 1,
        ),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const Loginscreen(),
        '/login': (context) => const Loginscreen(),
        '/signup': (context) => const Singupscreen(),
        '/admin': (context) => const AdminDashboard(),
        '/admin-profile': (context) => const AdminProfileScreen(),
        '/admin-settings': (context) => const AdminSettingsScreen(),
        '/client': (context) => const ClientDashboard(),
        '/cart': (context) => const ShoppingCartScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/categories': (context) => const CategoriesScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/search-history': (context) => const SearchHistoryScreen(),
        '/vendeur': (context) => const VendeurDashboard(),
        '/vendeur-add-product': (context) => const VendeurAddProductScreen(),
        '/vendeur-edit-product': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map<String, dynamic>) {
            return VendeurEditProductScreen(product: args);
          }
          throw Exception('Produit requis pour la modification');
        },
        '/vendeur-profile': (context) => const VendeurProfileScreen(),
        '/vendeur-settings': (context) => const VendeurSettingsScreen(),
      },
    );
  }
}
