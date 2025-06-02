import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'message.dart';
import 'gestion_user.dart';
import 'ajouter_livre.dart';
import 'historique_ventes.dart';
import 'recommandation.dart';
import 'reparation.dart';

class AdminEmpruntPage extends StatefulWidget {
  @override
  _AdminEmpruntPageState createState() => _AdminEmpruntPageState();
}

class _AdminEmpruntPageState extends State<AdminEmpruntPage> {
  List<dynamic> demandes = [];

  @override
  void initState() {
    super.initState();
    fetchDemandes();
  }

  void logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
  }

  Future<void> fetchDemandes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('http://192.168.68.120:3000/admin/emprunts-en-attente'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
    );

    if (response.statusCode == 200) {
      setState(() {
        demandes = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des demandes'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> updateStatus(int empruntId, String status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.put(
      Uri.parse('http://192.168.68.120:3000/admin/traiter-emprunt'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode({'id': empruntId, 'status': status}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Statut mis à jour'),
          backgroundColor: Colors.green,
        ),
      );
      fetchDemandes();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur mise à jour statut'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4E2D8),
      appBar: AppBar(
        title: Text('Demandes véhicule'),
        backgroundColor: Color(0xFFEED9B7),
      ),
      drawer: _buildDrawer(),
      body: Padding(
        padding: EdgeInsets.all(16),
        child:
            demandes.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                  itemCount: demandes.length,
                  itemBuilder: (context, index) {
                    final emprunt = demandes[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.white,
                      child: ListTile(
                        title: Text(
                          emprunt['titre'] ?? '–',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Utilisateur : ${emprunt['username']} (ID ${emprunt['user_id']})",
                            ),
                            Text(
                              "Date : ${emprunt['dateEmprunt'].toString().split('T')[0]}",
                            ),
                            Text("Statut : ${emprunt['admin_status']}"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              onPressed:
                                  () => updateStatus(emprunt['id'], 'accepté'),
                            ),
                            IconButton(
                              icon: Icon(Icons.cancel, color: Colors.redAccent),
                              onPressed:
                                  () => updateStatus(emprunt['id'], 'refusé'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
          _drawerItem(
            Icons.message,
            'Messages',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SendMessagePage()),
            ),
          ),
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
            () => Navigator.pop(context),
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
