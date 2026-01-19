import 'package:flutter/material.dart';
import 'package:miniprojet/widgets/TextFieldExe.dart';
import 'package:miniprojet/services/database.dart';

class Singupscreen extends StatefulWidget {
  const Singupscreen({super.key});

  @override
  State<Singupscreen> createState() => _SingupscreenState();
}

class _SingupscreenState extends State<Singupscreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  String selectedRole = 'client'; // Par défaut client
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (!MongoDatabase.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur de base de données. Veuillez redémarrer l\'application.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (emailController.text.isEmpty || 
        pwdController.text.isEmpty ||
        userNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Vérifier si l'email existe déjà
      final existingUser = await MongoDatabase.db
          .collection(MongoDatabase.userCollectionName)
          .where('email', isEqualTo: emailController.text.trim())
          .get();

      if (existingUser.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cet email est déjà utilisé'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Créer le nouvel utilisateur
      await MongoDatabase.db.collection(MongoDatabase.userCollectionName).add({
        'email': emailController.text.trim(),
        'password': pwdController.text, // You should hash this password
        'role': selectedRole,
        'username': userNameController.text,
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte créé avec succès! Veuillez vous connecter.'),
            backgroundColor: Colors.green,
          ),
        );

        // Rediriger vers le login après un délai
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'inscription: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                const SizedBox(height: 80),
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
                  'Create Account',
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
                  'Join us to discover exclusive products\nand personalized shopping experiences.',
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
                // Form Fields
                CustomTextFieldExe(
                  controller: userNameController,
                  labelText: "Username",
                  icon: Icons.person,
                ),
                const SizedBox(height: 20),
                CustomTextFieldExe(
                  controller: firstNameController,
                  labelText: "First Name",
                  icon: Icons.face,
                ),
                const SizedBox(height: 20),
                CustomTextFieldExe(
                  controller: lastNameController,
                  labelText: "Last Name",
                  icon: Icons.badge,
                ),
                const SizedBox(height: 20),
                CustomTextFieldExe(
                  controller: emailController,
                  labelText: "Email",
                  icon: Icons.email,
                ),
                const SizedBox(height: 20),
                CustomTextFieldExe(
                  controller: pwdController,
                  labelText: "Password",
                  icon: Icons.password,
                  obscure: true,
                ),
                const SizedBox(height: 20),
                // Sélecteur de rôle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(0),
                    border: Border.all(color: const Color(0xFF000000), width: 1),
                  ),
                  child: DropdownButton<String>(
                    value: selectedRole,
                    dropdownColor: const Color(0xFFFFFFFF),
                    style: const TextStyle(color: Color(0xFF000000)),
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                        value: 'client',
                        child: Text('Client'),
                      ),
                      DropdownMenuItem(
                        value: 'vendeur',
                        child: Text('Vendeur'),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedRole = newValue;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 40),
                // Sign Up Button with elegant styling
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading || !MongoDatabase.isConnected ? null : _signUp,
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
                            "SIGN UP",
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
                // Login link with elegant styling
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF666666),
                        letterSpacing: 0.5,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: const Text(
                        "Login",
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
