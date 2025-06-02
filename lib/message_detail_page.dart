import 'package:flutter/material.dart';

class MessageDetailPage extends StatelessWidget {
  final String sujet;
  final String message;
  final String type;
  final String date;
  final String sentAt;

  const MessageDetailPage({
    Key? key,
    required this.sujet,
    required this.message,
    required this.type,
    required this.date,
    required this.sentAt,
  }) : super(key: key);

  Color getTypeColor() {
    switch (type) {
      case 'Urgent':
        return Colors.red;
      case 'Information':
        return Colors.green;
      case 'Autre':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Détails du message"),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          color: Colors.brown[50],
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sujet,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[800]),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.category, color: getTypeColor()),
                    SizedBox(width: 8),
                    Text(
                      type,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: getTypeColor()),
                    ),
                    Spacer(),
                    Icon(Icons.date_range, color: Colors.brown),
                    SizedBox(width: 8),
                    Text(
                      date.split('T').first,
                      style: TextStyle(fontSize: 16, color: Colors.brown[700]),
                    ),
                  ],
                ),
                Divider(height: 32, thickness: 2),
                Text(
                  message,
                  style: TextStyle(fontSize: 18, color: Colors.brown[900]),
                ),
                Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "Envoyé le : ${sentAt.split('T').first}",
                    style: TextStyle(fontSize: 14, color: Colors.brown[600]),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
