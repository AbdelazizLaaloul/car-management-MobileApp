import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'user_page.dart';
import 'user_liste.dart';
import 'user_recommandation.dart';
import 'user_livre_emprunt.dart';
import 'message_detail_page.dart';

class MessagesPage extends StatefulWidget {
  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;

  Future<void> fetchMessages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print("Utilisateur non authentifié");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.68.120:3000/messages'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data is List) {
          setState(() {
            messages = List<Map<String, dynamic>>.from(data);
            isLoading = false;
          });
        } else {
          print("Erreur : Les données ne sont pas une liste");
          setState(() {
            isLoading = false;
          });
        }
      } else {
        print("Erreur serveur : ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur de connexion : $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  void logoutUser(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Messages")),
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.network(
              'https://media.istockphoto.com/id/1448787909/fr/vectoriel/drapeau-et-carte-du-maroc.jpg?s=612x612&w=0&k=20&c=cAGSChjor-CUtecs4xKLNDXt_qikJ7gEYPrU_D_GLiQ=',
              fit: BoxFit.cover,
              color: Colors.white.withOpacity(0.2), // Faded overlay
              colorBlendMode: BlendMode.dstATop,
            ),
          ),
          // Foreground content
          isLoading
              ? Center(child: CircularProgressIndicator())
              : messages.isEmpty
              ? Center(child: Text("Aucun message reçu"))
              : ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final content = msg['message'] ?? 'Message vide';
                  final sujet = msg['sujet'] ?? '';
                  final type = msg['type'] ?? '';
                  final date = msg['date'] ?? '';
                  final sentAt = msg['sent_at'] ?? '';

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    color: Colors.brown[50]?.withOpacity(0.9),
                    child: ListTile(
                      leading: Icon(Icons.message, color: Colors.brown[700]),
                      title: Text(
                        sujet,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        content.length > 60
                            ? "${content.substring(0, 60)}..."
                            : content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            type,
                            style: TextStyle(
                              color:
                                  type == 'Urgent' ? Colors.red : Colors.green,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            sentAt.split('T').first,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => MessageDetailPage(
                                  sujet: sujet,
                                  message: content,
                                  type: type,
                                  date: date,
                                  sentAt: sentAt,
                                ),
                          ),
                        );
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
