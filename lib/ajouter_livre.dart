// ajouter_livre.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';
import 'gestion_user.dart';
import 'message.dart';
import 'home_page.dart';
import 'book_detail_page.dart';
import 'recommandation.dart';
import 'adminemprunt.dart';
import 'historique_ventes.dart';
import 'reparation.dart';

class AjouterLivrePage extends StatefulWidget {
  final void Function(Map<String, String>) onBookAdded;

  AjouterLivrePage({required this.onBookAdded});

  @override
  _AjouterLivrePageState createState() => _AjouterLivrePageState();
}

class _AjouterLivrePageState extends State<AjouterLivrePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController titreController = TextEditingController();
  TextEditingController imageController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController disponibiliteController = TextEditingController(
    text: 'disponible',
  );

  void logoutUser(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
  }

  Future<void> ajouterLivre() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Token manquant. Veuillez vous reconnecter."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final body = {
        "titre": titreController.text,
        "image": imageController.text,
        "description": descriptionController.text,
        "disponibilite": disponibiliteController.text,
      };

      final response = await http.post(
        Uri.parse("http://192.168.68.120:3000/addBook"),
        headers: {"Content-Type": "application/json", "Authorization": token},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        widget.onBookAdded(body);
        Navigator.pop(context);
      } else {
        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur: ${error['error'] ?? 'Inconnue'}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    titreController.dispose();
    imageController.dispose();
    descriptionController.dispose();
    disponibiliteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4E2D8),
      appBar: AppBar(
        title: Text("Ajouter un véhicule"),
        backgroundColor: Color(0xFFEED9B7),
      ),
      drawer: _buildDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(titreController, "Titre", Icons.drive_eta),
              SizedBox(height: 12),
              _buildTextField(imageController, "Lien de l'image", Icons.image),
              SizedBox(height: 12),
              _buildTextField(
                descriptionController,
                "Description",
                Icons.description,
                maxLines: 3,
              ),
              SizedBox(height: 12),
              _buildTextField(
                disponibiliteController,
                "Disponibilité",
                Icons.check_circle,
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: ajouterLivre,
                icon: Icon(Icons.add, color: Colors.white),
                label: Text("Ajouter le véhicule"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.brown),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) => value!.isEmpty ? "Ce champ est requis" : null,
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEED9B7), Color(0xFFF3E5AB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                "Menu",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _drawerItem(
            Icons.home,
            "Accueil",
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            ),
          ),
          _drawerItem(
            Icons.message,
            "Messages",
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SendMessagePage()),
            ),
          ),
          _drawerItem(
            Icons.people,
            "Gestion Utilisateurs",
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UserListPage()),
            ),
          ),
          _drawerItem(
            Icons.directions_car,
            "Demandes véhicule",
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AdminEmpruntPage()),
            ),
          ),
          _drawerItem(
            Icons.build,
            "Recommandation Réparation",
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ListeRecommandationsPage()),
            ),
          ),
          _drawerItem(
            Icons.settings,
            "Réparation",
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ReparationPage()),
            ),
          ),
          _drawerItem(
            Icons.add,
            "Ajouter véhicule",
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AjouterLivrePage(onBookAdded: (_) {}),
              ),
            ),
          ),
          _drawerItem(
            Icons.history,
            "Historique ventes",
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HistoriqueventesPage()),
            ),
          ),
          Divider(),
          _drawerItem(Icons.logout, "Déconnexion", () => logoutUser(context)),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.brown),
      title: Text(title),
      onTap: onTap,
    );
  }
}
