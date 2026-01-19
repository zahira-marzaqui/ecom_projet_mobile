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
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Image.asset(
                "images/login.png",
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.lock,
                    size: 100,
                    color: Color(0xFF000000),
                  );
                },
              ),
              const SizedBox(height: 48),
              CustomTextFieldExe(controller: _emailController, labelText: "Email", icon: Icons.email),
              const SizedBox(height: 20),
              CustomTextFieldExe(controller: _pwdController, labelText: "Password", icon: Icons.password, obscure: true),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading || !MongoDatabase.isConnected ? null : _login,
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
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
              ),
              if (!MongoDatabase.isConnected)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Database not connected. Please restart the app.',
                    style: const TextStyle(color: Color(0xFF000000)),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account ?", style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/signup');
                    },
                    child: const Text(
                      "Sign up here",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF000000),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF000000),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
