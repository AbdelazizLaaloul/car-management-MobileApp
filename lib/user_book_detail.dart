import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserBookDetailPage extends StatefulWidget {
  final String id;

  const UserBookDetailPage({required this.id, Key? key}) : super(key: key);

  @override
  _UserBookDetailPageState createState() => _UserBookDetailPageState();
}

class _UserBookDetailPageState extends State<UserBookDetailPage> {
  String titre = 'Titre inconnu';
  String image = '';
  String description = 'Aucune description disponible';
  String disponibilite = 'inconnu';
  DateTime? selectedDate;
  bool isLoading = true;

  final Color primaryColor = Colors.orange;
  final Color secondaryColor = Colors.orangeAccent;

  @override
  void initState() {
    super.initState();
    fetchBookDetails();
  }

  void fetchBookDetails() async {
    if (widget.id.isEmpty) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse("http://192.168.68.120:3000/livres/${widget.id}"),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          titre = data['titre'] ?? 'Titre inconnu';
          image = data['image'] ?? '';
          description = data['description'] ?? 'Aucune description disponible';
          disponibilite = data['disponibilite']?.toString() ?? 'Inconnue';
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> addToPersonalList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse("http://192.168.68.120:3000/addToPersonalList"),
        headers: {'Content-Type': 'application/json', 'Authorization': token},
        body: jsonEncode({'livreId': widget.id}),
      );
      final msg =
          response.statusCode == 200
              ? "Livre ajouté à votre liste personnelle"
              : "Erreur lors de l'ajout à la liste";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur : $e")));
    }
  }

  void showDateSelector() async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now.subtract(Duration(days: 365)),
      lastDate: now.add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> requestCard() async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });

      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token == null || token.isEmpty) return;

        final response = await http.post(
          Uri.parse("http://192.168.68.120:3000/emprunter"),
          headers: {'Content-Type': 'application/json', 'Authorization': token},
          body: jsonEncode({
            'livreId': widget.id,
            'date': picked.toIso8601String(),
          }),
        );

        final msg =
            response.statusCode == 200
                ? "Demande envoyée avec succès pour le ${picked.toLocal().toString().split(' ')[0]}"
                : "Erreur lors de l'envoi de la demande";
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur : $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color(0xFFEED9B7), title: Text(titre)),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child:
                          image.isNotEmpty
                              ? Image.network(
                                image,
                                height: 250,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                              : Container(
                                height: 250,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 80,
                                  color: Colors.grey[600],
                                ),
                              ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      titre,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Disponibilité : $disponibilite",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            disponibilite.toLowerCase() == "disponible"
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedDate != null
                                ? 'Date sélectionnée : ${selectedDate!.toLocal().toString().split(' ')[0]}'
                                : 'Aucune date sélectionnée',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_today, color: primaryColor),
                          onPressed: showDateSelector,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: addToPersonalList,
                            icon: Icon(Icons.favorite_border),
                            label: Text("Ma liste"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: StadiumBorder(),
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: requestCard,
                            icon: Icon(Icons.card_giftcard),
                            label: Text("Demander"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: secondaryColor,
                              shape: StadiumBorder(),
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      color: secondaryColor.withOpacity(0.2),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Description",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(description, style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
