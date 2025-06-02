import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BookDetailPage extends StatefulWidget {
  final String id;

  const BookDetailPage({required this.id, Key? key}) : super(key: key);

  @override
  _BookDetailPageState createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  String titre = '';
  String image = '';
  String description = '';
  String dateAjout = '';
  String disponibilite = '';
  bool isLoading = true;

  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dispoController = TextEditingController();

  final Color primaryColor = Colors.orange;
  final Color secondaryColor = Colors.orangeAccent;

  @override
  void initState() {
    super.initState();
    _fetchBookDetails();
  }

  Future<void> _fetchBookDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    if (token.isEmpty) return;

    final response = await http.get(
      Uri.parse("http://192.168.68.120:3000/livres/${widget.id}"),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        titre = data['titre'] ?? '';
        image = data['image'] ?? '';
        description = data['description'] ?? '';
        dateAjout = data['date_ajout'] ?? '';
        disponibilite = data['disponibilite'] ?? '';

        _titreController.text = titre;
        _imageController.text = image;
        _descriptionController.text = description;
        _dispoController.text = disponibilite;

        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text("Modifier les détails du livre"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _titreController,
                    decoration: InputDecoration(labelText: "Titre"),
                  ),
                  TextField(
                    controller: _imageController,
                    decoration: InputDecoration(labelText: "URL de l'image"),
                  ),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: "Description"),
                    maxLines: 3,
                  ),
                  TextField(
                    controller: _dispoController,
                    decoration: InputDecoration(labelText: "Disponibilité"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () {
                  _updateBook();
                  Navigator.of(ctx).pop();
                },
                child: Text("Enregistrer"),
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              ),
            ],
          ),
    );
  }

  Future<void> _updateBook() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final updatedData = {
      'titre': _titreController.text,
      'image': _imageController.text,
      'description': _descriptionController.text,
      'disponibilite': _dispoController.text,
    };

    final response = await http.put(
      Uri.parse("http://192.168.68.120:3000/livres/${widget.id}"),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
      body: jsonEncode(updatedData),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Mise à jour réussie")));
      _fetchBookDetails();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Échec de la mise à jour")));
    }
  }

  Future<void> _deleteBook() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.delete(
      Uri.parse("http://192.168.68.120:3000/livres/${widget.id}"),
      headers: {'Content-Type': 'application/json', 'Authorization': token},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Suppression réussie")));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Échec de la suppression")));
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _imageController.dispose();
    _descriptionController.dispose();
    _dispoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFEED9B7),
        title: Text(titre.isEmpty ? "Détails du livre" : titre),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
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
                      "Date d'ajout : $dateAjout",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Disponibilité : $disponibilite",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            disponibilite == 'disponible'
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      color: secondaryColor.withOpacity(0.2),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          description,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _showEditDialog,
                            icon: Icon(Icons.edit),
                            label: Text("Modifier"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: StadiumBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                () => showDialog(
                                  context: context,
                                  builder:
                                      (ctx) => AlertDialog(
                                        title: Text("Confirmer la suppression"),
                                        content: Text(
                                          "Voulez-vous supprimer ce livre ?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(ctx).pop(),
                                            child: Text("Annuler"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              _deleteBook();
                                              Navigator.of(ctx).pop();
                                            },
                                            child: Text("Supprimer"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                ),
                            icon: Icon(Icons.delete),
                            label: Text("Supprimer"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: StadiumBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }
}
