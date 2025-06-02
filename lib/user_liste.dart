import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'user_message.dart';
import 'user_book_detail.dart';
import 'user_recommandation.dart';
import 'user_liste.dart';
import 'user_livre_emprunt.dart';
import 'user_page.dart';

class ListePage extends StatefulWidget {
  const ListePage({Key? key}) : super(key: key);

  @override
  _ListePageState createState() => _ListePageState();
}

class _ListePageState extends State<ListePage> {
  List<Map<String, dynamic>> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserBooks();
  }

  void logoutUser(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  }

  Future<void> fetchUserBooks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Token invalide ou manquant")));
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("http://192.168.68.120:3000/listePersonnelle"),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          books = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la récupération des livres")),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur : $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ma Liste")),
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://media.istockphoto.com/id/1448787909/fr/vectoriel/drapeau-et-carte-du-maroc.jpg?s=612x612&w=0&k=20&c=cAGSChjor-CUtecs4xKLNDXt_qikJ7gEYPrU_D_GLiQ=',
              fit: BoxFit.cover,
              color: Colors.white.withOpacity(0.2),
              colorBlendMode: BlendMode.dstATop,
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : books.isEmpty
              ? Center(child: Text("Aucun livre trouvé"))
              : ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  final title = book['titre'] ?? 'Titre inconnu';
                  final dateAjout = book['date_ajout'] ?? '';

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    color: Colors.brown[50]?.withOpacity(0.9),
                    child: ListTile(
                      leading: Icon(Icons.book, color: Colors.brown[700]),
                      title: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text("Ajouté le: $dateAjout"),
                      onTap: () {
                        // Ajoutez votre logique ici
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
          _buildDrawerHeader(),
          _drawerItem(Icons.home, "Accueil", () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => UserPage()),
            );
          }),
          _drawerItem(Icons.message, "Messages", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MessagesPage()),
            );
          }),
          _drawerItem(Icons.list, "Mon Liste", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ListePage()),
            );
          }),
          _drawerItem(Icons.build, "Recommandations Réparations", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RecommanderLivrePage()),
            );
          }),
          _drawerItem(Icons.directions_car, "Les Cars demandés", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UserAcceptedBooksPage()),
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
            color: Colors.black,
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
