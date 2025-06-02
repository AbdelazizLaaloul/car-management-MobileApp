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
import 'historique_ventes.dart';
import 'reparation.dart';

class ListeRecommandationsPage extends StatefulWidget {
  @override
  _ListeRecommandationsPageState createState() =>
      _ListeRecommandationsPageState();
}

class _ListeRecommandationsPageState extends State<ListeRecommandationsPage> {
  List<Map<String, dynamic>> recommandations = [];
  List<Map<String, String>> books = [];

  @override
  void initState() {
    super.initState();
    fetchRecommandations();
  }

  void logoutUser(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  }

  Future<void> fetchRecommandations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('http://192.168.68.120:3000/recommandations'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data != null && data is List) {
        setState(() {
          recommandations = List<Map<String, dynamic>>.from(data);
        });
      } else {
        print("Erreur : Les données ne sont pas une liste");
      }
    } else {
      print("Erreur serveur : ${response.statusCode}");
    }
  }

  void handleBookAdded(Map<String, String> newBook) {
    setState(() {
      books.insert(0, newBook);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(title: Text("Recommandations")),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://media.istockphoto.com/id/1448787909/fr/vectoriel/drapeau-et-carte-du-maroc.jpg?s=612x612&w=0&k=20&c=cAGSChjor-CUtecs4xKLNDXt_qikJ7gEYPrU_D_GLiQ=',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.9),
              BlendMode.lighten,
            ),
          ),
        ),
        child:
            recommandations.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: recommandations.length,
                  itemBuilder: (context, index) {
                    final reco = recommandations[index];

                    final userId = reco['user_id']?.toString() ?? '?';
                    final titre = reco['titre'] ?? 'Sans titre';
                    final description = reco['description'] ?? '';
                    final dateCreation =
                        reco['date_creation'] ?? 'Date inconnue';

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      color: Colors.teal[50],
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal[200],
                          child: Icon(Icons.settings, color: Colors.teal[900]),
                        ),
                        title: Text(
                          titre,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.teal[900],
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            Text(
                              description,
                              style: TextStyle(color: Colors.teal[700]),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "Utilisateur: $userId | Date: $dateCreation",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.teal[800],
                              ),
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
          _buildDrawerHeader(),
          _drawerItem(Icons.home, "Accueil", () {
            Navigator.push(
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ReparationPage()),
            );
          }),
          _drawerItem(Icons.add, "Ajouter véhicule", () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AjouterLivrePage(onBookAdded: handleBookAdded),
              ),
            );
          }),
          _drawerItem(Icons.history, "Historique de Demmande", () {
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
            color: Colors.white,
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
