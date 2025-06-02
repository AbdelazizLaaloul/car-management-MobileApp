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

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, String>> books = [];
  bool isLoading = false;
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
      List<dynamic> data = jsonDecode(response.body);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
      appBar: AppBar(
        title: Text("Véhicules disponibles"),
        backgroundColor: Color(0xFFEED9B7),
      ),
      backgroundColor: Color(0xFFF4E2D8),
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
                      : _buildBookGrid(),
            ),
          ],
        ),
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

  Widget _buildBookGrid() {
    return GridView.builder(
      itemCount: books.length,
      padding: const EdgeInsets.only(bottom: 60),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final book = books[index];
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
                MaterialPageRoute(
                  builder: (_) => UserBookDetailPage(id: book["id"]!),
                ),
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
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
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
      },
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
          _drawerItem(Icons.list, "Ma Liste", () {
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
