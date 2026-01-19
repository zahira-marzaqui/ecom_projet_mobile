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
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            children: [
              Image.asset("images/singup.png", height: 300,),
              const SizedBox(height: 32),
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
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading || !MongoDatabase.isConnected ? null : _signUp,
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
                  const Text("You have an account ?", style: TextStyle(fontSize: 14, color: Color(0xFF666666))),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: const Text(
                      "Login here",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF000000),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF000000),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
