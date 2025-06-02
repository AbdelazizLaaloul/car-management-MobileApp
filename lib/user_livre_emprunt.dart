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

class UserAcceptedBooksPage extends StatefulWidget {
  @override
  _UserAcceptedBooksPageState createState() => _UserAcceptedBooksPageState();
}

class _UserAcceptedBooksPageState extends State<UserAcceptedBooksPage> {
  List<dynamic> livresAcceptees = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAcceptedBooks();
  }

  void logoutUser(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  }

  Future<void> fetchAcceptedBooks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('http://192.168.68.120:3000/livres-acceptees'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token ?? '',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        livresAcceptees = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la récupération des livres")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cars acceptés')),
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
          Padding(
            padding: const EdgeInsets.all(10.0),
            child:
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : livresAcceptees.isEmpty
                    ? Center(
                      child: Text(
                        "Aucun Cars accepté",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                    : ListView.builder(
                      itemCount: livresAcceptees.length,
                      itemBuilder: (context, index) {
                        final livre = livresAcceptees[index];
                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Colors.brown[50]?.withOpacity(0.9),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            title: Text(
                              livre['titre'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              'Emprunté le: ${livre['dateEmprunt']}',
                              style: TextStyle(fontSize: 14),
                            ),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => UserBookDetailPage(
                                        id: livre['id'].toString(),
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
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
