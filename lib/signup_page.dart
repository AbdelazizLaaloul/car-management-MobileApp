import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:http/http.dart' as http;

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;

  Future<void> registerUser() async {
    var url = Uri.parse("http://192.168.68.120:3000/signup");
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": usernameController.text,
        "email": emailController.text,
        "password": passwordController.text,
      }),
    );

    var data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("✅ Inscription réussie !")));
      Navigator.pushNamed(context, "/login");
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ ${data["error"]}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/image.png', // ⬅️ Remplacez par votre image
              fit: BoxFit.cover,
            ),
          ),
          // Foreground content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: size.height - MediaQuery.of(context).padding.top,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/WhatsApp_Image_2025-05-11_at_16.52.19_aa968687-removebg-preview.png',
                            width: size.width * 0.55,
                          ),
                        ),
                        const SizedBox(height: 24),

                        AnimatedTextKit(
                          animatedTexts: [
                            TyperAnimatedText(
                              'Créer un compte',
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              speed: Duration(milliseconds: 80),
                            ),
                          ],
                          isRepeatingAnimation: false,
                        ),
                        const SizedBox(height: 16),

                        AnimatedTextKit(
                          animatedTexts: [
                            TyperAnimatedText(
                              'Bienvenue ! Veuillez renseigner vos informations pour continuer.',
                              textStyle: TextStyle(
                                color: Color.fromARGB(243, 3, 187, 248),
                                fontSize: 16,
                                height: 1.4,
                              ),
                              speed: Duration(milliseconds: 30),
                            ),
                          ],
                          isRepeatingAnimation: false,
                        ),
                        const SizedBox(height: 32),

                        // Username Field
                        TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            labelText: 'Nom complet',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            fillColor: Colors.white.withOpacity(0.8),
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Email Field
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            fillColor: Colors.white.withOpacity(0.8),
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(
                                  () => obscurePassword = !obscurePassword,
                                );
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            fillColor: Colors.white.withOpacity(0.8),
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Signup Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: registerUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(243, 236, 240, 1),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'S’inscrire',
                              style: TextStyle(
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/login'),
                          child: Text(
                            "Vous avez déjà un compte ? Connectez-vous",
                            style: TextStyle(
                              color: Color.fromARGB(243, 236, 240, 1),
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
