import 'package:flutter/material.dart';
import 'package:miniprojet/widgets/TextFieldExe.dart';
import 'package:miniprojet/services/database.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!MongoDatabase.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur de base de données. Veuillez redémarrer l\'application.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_emailController.text.isEmpty || _pwdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final snapshot = await MongoDatabase.db
          .collection(MongoDatabase.userCollectionName)
          .where('email', isEqualTo: _emailController.text.trim())
          .where('password', isEqualTo: _pwdController.text)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final userDoc = snapshot.docs.first;
        final user = userDoc.data();
        user['_id'] = userDoc.id; // Add document ID

        MongoDatabase.currentUser = user;
        String role = user['role'];
        
        switch (role) {
          case 'client':
            Navigator.of(context).pushReplacementNamed('/client');
            break;
          case 'admin':
            Navigator.of(context).pushReplacementNamed('/admin');
            break;
          case 'vendeur':
            Navigator.of(context).pushReplacementNamed('/vendeur');
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Rôle utilisateur non reconnu'),
                backgroundColor: Colors.red,
              ),
            );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email ou mot de passe incorrect'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de connexion: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                // Decorative line
                Container(
                  width: 60,
                  height: 2,
                  color: const Color(0xFF000000),
                ),
                const SizedBox(height: 40),
                // Brand Title with elegant styling
                const Text(
                  'LUXE',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF000000),
                    letterSpacing: 8,
                    fontFamily: 'serif',
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle
                const Text(
                  'PREMIUM COLLECTION',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF666666),
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 80),
                // Heading with elegant serif
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF000000),
                    letterSpacing: 1,
                    fontFamily: 'serif',
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                // Description with refined typography
                const Text(
                  'Sign in to continue your journey with our\nexclusive collection of premium products.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF666666),
                    height: 1.6,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 60),
                // Email Field
                CustomTextFieldExe(controller: _emailController, labelText: "Email", icon: Icons.email),
                const SizedBox(height: 20),
                // Password Field
                CustomTextFieldExe(controller: _pwdController, labelText: "Password", icon: Icons.password, obscure: true),
                const SizedBox(height: 40),
                // Login Button with elegant styling
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading || !MongoDatabase.isConnected ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000000),
                      foregroundColor: const Color(0xFFFFFFFF),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFFFFF)),
                            ),
                          )
                        : const Text(
                            "LOGIN",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              letterSpacing: 3,
                            ),
                          ),
                  ),
                ),
                if (!MongoDatabase.isConnected)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Database not connected. Please restart the app.',
                      style: const TextStyle(color: Color(0xFF666666), fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 48),
                // Elegant divider
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color(0xFFE5E5E5),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFF999999),
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color(0xFFE5E5E5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Sign up link with elegant styling
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF666666),
                        letterSpacing: 0.5,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/signup');
                      },
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF000000),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                          decoration: TextDecoration.underline,
                          decorationThickness: 1.5,
                          decorationColor: Color(0xFF000000),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
