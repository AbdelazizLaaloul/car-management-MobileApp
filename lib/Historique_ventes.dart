import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';
import 'gestion_user.dart';
import 'message.dart';
import 'ajouter_livre.dart';
import 'book_detail_page.dart';
import 'recommandation.dart';
import 'adminemprunt.dart';
import 'home_page.dart';
import 'reparation.dart';

class HistoriqueventesPage extends StatefulWidget {
  @override
  _HistoriqueventesPageState createState() => _HistoriqueventesPageState();
}

class _HistoriqueventesPageState extends State<HistoriqueventesPage> {
  List<dynamic> ventes = [];

  @override
  void initState() {
    super.initState();
    fetchVentes();
  }

  Future<void> fetchVentes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('http://192.168.68.120:3000/historique-ventes'),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
    );

    if (response.statusCode == 200) {
      setState(() {
        ventes = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du chargement de l'historique")),
      );
    }
  }

  void logoutUser(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historique des ventes')),
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          // ✅ Background image
          Positioned.fill(
            child: Image.network(
              'https://media.istockphoto.com/id/1448787909/fr/vectoriel/drapeau-et-carte-du-maroc.jpg?s=612x612&w=0&k=20&c=cAGSChjor-CUtecs4xKLNDXt_qikJ7gEYPrU_D_GLiQ=',
              fit: BoxFit.cover,
            ),
          ),
          // ✅ Semi-transparent white overlay
          Container(color: Colors.white.withOpacity(0.8)),
          // ✅ Main content
          ventes.isEmpty
              ? Center(child: Text("Aucune vente enregistrée"))
              : ListView.builder(
                itemCount: ventes.length,
                itemBuilder: (context, index) {
                  final vente = ventes[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.brown[50],
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12),
                      leading:
                          vente['image'] != null && vente['image'].isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  vente['image'],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                              : Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.book,
                                  color: Colors.grey[600],
                                ),
                              ),
                      title: Text(
                        vente['titre'] ?? '—',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4),
                          Text("Utilisateur : ${vente['username'] ?? '—'}"),
                          SizedBox(height: 2),
                          Text("Date d'ajout : ${vente['date_ajout'] ?? '—'}"),
                          SizedBox(height: 2),
                          Text(
                            "Disponibilité : ${vente['disponibilite'] ?? '—'}",
                            style: TextStyle(
                              color:
                                  vente['disponibilite'] == 'disponible'
                                      ? Colors.green
                                      : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        if (vente['id'] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => BookDetailPage(
                                    id: vente['id'].toString(),
                                  ),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
        ],
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
