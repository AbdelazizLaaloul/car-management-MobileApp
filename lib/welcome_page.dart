import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 248, 248),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Logo au centre
              Center(
                child: Image.asset(
                  'assets/WhatsApp_Image_2025-05-11_at_16.52.19_aa968687-removebg-preview.png',
                  width: 250,
                ),
              ),

              const SizedBox(height: 24),

              // Animation du titre principal
              AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    'Votre mobilité commence ici',
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    speed: Duration(milliseconds: 80),
                  ),
                ],
                isRepeatingAnimation: false,
                totalRepeatCount: 1,
              ),

              const SizedBox(height: 16),

              // Animation du sous-titre
              AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    'Bienvenue dans l’application de réservation de voitures de la commune de Dakhla. Réservez votre voiture dès maintenant !',
                    textStyle: TextStyle(
                      color: Color.fromARGB(243, 236, 240, 1),
                      fontSize: 16,
                      height: 1.4,
                    ),
                    speed: Duration(milliseconds: 30),
                  ),
                ],
                isRepeatingAnimation: false,
                totalRepeatCount: 1,
              ),

              Spacer(),

              // Get Started button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(243, 236, 240, 1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Get started',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Login link
              RichText(
                text: TextSpan(
                  text: 'Already have an account? ',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                  children: [
                    TextSpan(
                      text: 'Log in',
                      style: TextStyle(
                        color: Color.fromARGB(243, 236, 240, 1),
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, '/login');
                            },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
