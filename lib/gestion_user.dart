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

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<Map<String, dynamic>> users = [];
  List<Map<String, String>> books = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  void logoutUser(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  }

  Future<void> fetchUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final response = await http.get(
      Uri.parse("http://192.168.68.120:3000/users"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        users = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      print("Erreur lors du chargement des utilisateurs: ${response.body}");
    }
  }

  void deleteUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirmer la suppression'),
            content: Text('Voulez-vous vraiment supprimer cet utilisateur ?'),
            actions: [
              TextButton(
                child: Text('Annuler'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text('Supprimer', style: TextStyle(color: Colors.red)),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    final response = await http.delete(
      Uri.parse("http://192.168.68.120:3000/users/$userId"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      setState(() {
        users.removeWhere((user) => user["id"] == userId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Utilisateur supprimé avec succès")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur lors de la suppression")));
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
      appBar: AppBar(title: Text("Gestion des utilisateurs")),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              "https://media.istockphoto.com/id/1448787909/fr/vectoriel/drapeau-et-carte-du-maroc.jpg?s=612x612&w=0&k=20&c=cAGSChjor-CUtecs4xKLNDXt_qikJ7gEYPrU_D_GLiQ=",
              fit: BoxFit.cover,
              color: Colors.white.withOpacity(0.2),
              colorBlendMode: BlendMode.dstATop,
            ),
          ),
          users.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    color: Colors.brown[50]?.withOpacity(0.9),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.brown[200],
                        child: Icon(Icons.person, color: Colors.brown[700]),
                      ),
                      title: Text(
                        user["username"] ?? 'Utilisateur',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.brown[900],
                        ),
                      ),
                      subtitle: Text(
                        user["email"] ?? 'Pas d\'email',
                        style: TextStyle(color: Colors.brown[700]),
                      ),
                      trailing: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        children: [
                          Text(
                            "ID: ${user["id"]}",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.brown[700],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red[700]),
                            tooltip: "Supprimer l'utilisateur",
                            onPressed: () => deleteUser(user["id"]),
                          ),
                        ],
                      ),
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
