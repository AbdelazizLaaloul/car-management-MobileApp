// home_page.dart

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
import 'historique_ventes.dart';
import 'reparation.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, String>> books = [];
  bool isLoading = false;

  // Track which card is zoomed
  int? zoomedCardIndex;

  @override
  void initState() {
    super.initState();
    fetchBooks("");
  }

  void logoutUser(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  }

  Future<void> fetchBooks(String searchQuery) async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Token manquant")));
      setState(() => isLoading = false);
      return;
    }

    final response = await http.get(
      Uri.parse("http://192.168.68.120:3000/livres"),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        books =
            data
                .map<Map<String, String>>(
                  (book) => {
                    "id": book["id"].toString(),
                    "titre": book["titre"] ?? "",
                    "image": book["image"] ?? "",
                    "disponibilite": book["disponibilite"] ?? "indisponible",
                  },
                )
                .where(
                  (book) => book["titre"]!.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ),
                )
                .toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du chargement des livres")),
      );
    }

    setState(() => isLoading = false);
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
      appBar: AppBar(
        title: Text("Véhicules"),
        backgroundColor: Color(0xFFEED9B7),
      ),
      backgroundColor: Color(0xFFF4E2D8), // desert tone
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            SizedBox(height: 20),
            Expanded(
              child:
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : books.isEmpty
                      ? Center(child: Text("Aucun véhicule trouvé"))
                      : LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount =
                              constraints.maxWidth < 600 ? 2 : 3;
                          return GridView.builder(
                            itemCount: books.length,
                            padding: const EdgeInsets.only(bottom: 60),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.75,
                                ),
                            itemBuilder: (context, index) {
                              final book = books[index];
                              return _buildCarCard(book, index);
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AjouterLivrePage(onBookAdded: handleBookAdded),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.brown,
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: searchController,
      onChanged: fetchBooks,
      decoration: InputDecoration(
        hintText: "Rechercher un véhicule...",
        prefixIcon: Icon(Icons.search, color: Colors.brown),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCarCard(Map<String, String> book, int index) {
    final imageUrl = book["image"]!;
    final disponibilite = book["disponibilite"];
    final isAvailable = disponibilite == 'disponible';

    return GestureDetector(
      onTap: () {
        setState(() => zoomedCardIndex = index);
        Future.delayed(Duration(milliseconds: 200), () {
          setState(() => zoomedCardIndex = null);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => BookDetailPage(id: book["id"]!)),
          );
        });
      },
      child: AnimatedScale(
        scale: zoomedCardIndex == index ? 1.1 : 1.0,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF6D8AE), Color(0xFFF3E5AB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child:
                      imageUrl.isNotEmpty
                          ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                ),
                          )
                          : Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.image,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      book["titre"] ?? "",
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.brown[800],
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Disponibilité: $disponibilite",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isAvailable ? Colors.green : Colors.red,
                      ),
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

  Drawer _buildDrawer() {
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
          _drawerItem(Icons.history, "Historique des ventes", () {
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
