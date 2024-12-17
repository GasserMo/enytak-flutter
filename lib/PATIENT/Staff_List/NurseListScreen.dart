import 'package:flutter/material.dart';

class NurseListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> nurses;

  // Constructor to accept the list of nurses
  const NurseListScreen({super.key, required this.nurses});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top-Rated Nurses'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: nurses.length,
        itemBuilder: (context, index) {
          final nurse = nurses[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage(nurse['photo']),
              ),
              title: Text(
                nurse['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nurse['specialization']),
                  const SizedBox(height: 4),
                  Text('Rating: ${nurse['rating']}'),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                
              },
            ),
          );
        },
      ),
    );
  }
}
