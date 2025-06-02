import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';
import 'gestion_user.dart';
import 'message.dart';
import 'ajouter_livre.dart';
import 'book_detail_page.dart';
import 'recommandation.dart';
import 'adminemprunt.dart';
import 'home_page.dart';
import 'historique_ventes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReparationPage extends StatefulWidget {
  @override
  _ReparationPageState createState() => _ReparationPageState();
}

class _ReparationPageState extends State<ReparationPage> {
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _coutController = TextEditingController();

  void logoutUser(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
  }

  void _submitForm() {
    final description = _descriptionController.text;
    final date = _dateController.text;
    final cout = _coutController.text;

    // TODO: Envoi vers la base de données si nécessaire

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Demande de réparation envoyée !')));

    _descriptionController.clear();
    _dateController.clear();
    _coutController.clear();
  }

  Future<void> _exportPDF() async {
    final url = Uri.parse('http://192.168.68.120:3000/generate-pdf');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'description': _descriptionController.text,
        'date': _dateController.text,
        'cout': _coutController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF généré avec succès !')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la génération du PDF.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4E2D8),
      appBar: AppBar(
        title: Text('Réparation'),
        backgroundColor: Color(0xFFEED9B7),
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Formulaire de réparation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description du problème',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 12),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Date souhaitée',
                hintText: 'JJ/MM/AAAA',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _coutController,
              decoration: InputDecoration(
                labelText: 'Coût estimé',
                prefixText: 'DHS ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Soumettre'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _exportPDF,
                    child: Text('Exporter PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(),
          _drawerItem(Icons.home, "Accueil", () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          }),
          _drawerItem(Icons.message, "Messages", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SendMessagePage()),
            );
          }),
          _drawerItem(Icons.people, "Gestion Utilisateurs", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UserListPage()),
            );
          }),
          _drawerItem(Icons.directions_car, "Demandes véhicule", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AdminEmpruntPage()),
            );
          }),
          _drawerItem(Icons.build, "Recommandation Réparation", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ListeRecommandationsPage()),
            );
          }),
          _drawerItem(Icons.settings, "Réparation", () {
            Navigator.pop(context);
          }),
          _drawerItem(Icons.add, "Ajouter véhicule", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AjouterLivrePage(onBookAdded: (_) {}),
              ),
            );
          }),
          _drawerItem(Icons.history, "Historique de Demande", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HistoriqueventesPage()),
            );
          }),
          Divider(),
          _drawerItem(Icons.logout, "Déconnexion", () => logoutUser(context)),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
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
            color: const Color.fromARGB(255, 0, 0, 0),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
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
