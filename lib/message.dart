// send_message_page.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'gestion_user.dart';
import 'adminemprunt.dart';
import 'recommandation.dart';
import 'reparation.dart';
import 'ajouter_livre.dart';
import 'historique_ventes.dart';

class SendMessagePage extends StatefulWidget {
  @override
  _SendMessagePageState createState() => _SendMessagePageState();
}

class _SendMessagePageState extends State<SendMessagePage> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController sujetController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  String? selectedType;
  DateTime? selectedDate;
  bool isSending = false;

  Future<void> sendMessage() async {
    final idUtilisateur = idController.text.trim();
    final sujet = sujetController.text.trim();
    final message = messageController.text.trim();
    final type = selectedType;
    final date = selectedDate?.toIso8601String();

    if (idUtilisateur.isEmpty ||
        sujet.isEmpty ||
        message.isEmpty ||
        type == null ||
        date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tous les champs sont obligatoires"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSending = true);
    try {
      final response = await http.post(
        Uri.parse("http://192.168.68.120:3000/sendMessage"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': idUtilisateur,
          'sujet': sujet,
          'message': message,
          'type': type,
          'date': date,
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Message envoyé à $idUtilisateur"),
            backgroundColor: Colors.green,
          ),
        );
        idController.clear();
        sujetController.clear();
        messageController.clear();
        setState(() {
          selectedType = null;
          selectedDate = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Échec de l'envoi"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur réseau"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isSending = false);
    }
  }

  void _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4E2D8),
      appBar: AppBar(
        title: Text('Messages'),
        backgroundColor: Color(0xFFEED9B7),
      ),
      drawer: _buildDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWide ? 600 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.message, size: 48, color: Colors.brown[700]),
                  SizedBox(height: 16),
                  _buildTextField(idController, "ID utilisateur", Icons.person),
                  SizedBox(height: 16),
                  _buildTextField(sujetController, "Sujet", Icons.subject),
                  SizedBox(height: 16),
                  _buildTextField(
                    messageController,
                    "Votre message",
                    Icons.edit,
                    maxLines: 5,
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items:
                        ['Urgent', 'Information', 'Autre']
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => setState(() => selectedType = value),
                    decoration: InputDecoration(
                      labelText: "Type",
                      prefixIcon: Icon(Icons.category, color: Colors.brown),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: "Date",
                        prefixIcon: Icon(Icons.date_range, color: Colors.brown),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      child: Text(
                        selectedDate != null
                            ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                            : "Sélectionnez une date",
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: isSending ? null : sendMessage,
                    icon:
                        isSending
                            ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Icon(Icons.send, color: Colors.white),
                    label: Text(isSending ? 'Envoi...' : 'Envoyer'),
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
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
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
                'Menu',
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
            'Accueil',
            () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            ),
          ),
          _drawerItem(Icons.message, 'Messages', () => Navigator.pop(context)),
          _drawerItem(
            Icons.people,
            'Gestion Utilisateurs',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UserListPage()),
            ),
          ),
          _drawerItem(
            Icons.directions_car,
            'Demandes véhicule',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AdminEmpruntPage()),
            ),
          ),
          _drawerItem(
            Icons.build,
            'Recommandation Réparation',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ListeRecommandationsPage()),
            ),
          ),
          _drawerItem(
            Icons.settings,
            'Réparation',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ReparationPage()),
            ),
          ),
          _drawerItem(
            Icons.add,
            'Ajouter véhicule',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AjouterLivrePage(onBookAdded: (book) {}),
              ),
            ),
          ),
          _drawerItem(
            Icons.history,
            'Historique ventes',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HistoriqueventesPage()),
            ),
          ),
          Divider(),
          _drawerItem(Icons.logout, 'Déconnexion', logoutUser),
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
