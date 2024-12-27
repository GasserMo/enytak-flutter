import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic> userData = {};
  String? token;
  int? userId;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access');
    userId = prefs.getInt('userId');

    if (token == null || userId == null) {
      _showErrorSnackBar("No token or user ID found. Please login first.");
      return;
    }

    final String apiUrl = 'http://164.92.111.149/api/users/$userId/';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = json.decode(utf8.decode(response.bodyBytes));
        });
      } else {
        String errorMsg =
            'Error: Unable to fetch user data. Status code: ${response.statusCode}';
        _showErrorSnackBar(errorMsg);
      }
    } catch (e) {
      String errorMsg = 'Failed to load user data: $e';
      _showErrorSnackBar(errorMsg);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access');
    await prefs.remove('userId');

    Fluttertoast.showToast(
      msg: "Logged out successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.teal,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    Navigator.pushReplacementNamed(context, '/Login_Signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => {Navigator.pop(context)},
            icon: Icon(Icons.arrow_back)),
        title: const Text('User Profile'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildMedicalDetails(),
            const SizedBox(height: 20),
            _buildLifestyleSection(),
            const SizedBox(height: 20),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: userData['profile_image'] != null
                ? NetworkImage(userData['profile_image'])
                : const AssetImage("assets/user_profile.jpg") as ImageProvider,
          ),
          const SizedBox(height: 10),
          Text(
            userData['username'] ?? 'No Username',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userData['email'] ?? 'No Email',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            userData['phone_number'] ?? 'No Phone Number',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalDetails() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Medical Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow("Full Name", userData['full_name'] ?? 'N/A'),
            _buildDetailRow("Birth Date", userData['birth_date'] ?? 'N/A'),
            _buildDetailRow("Gender", userData['gender'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildLifestyleSection() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Lifestyle Preferences",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
                "Is Verified", userData['is_verified'] == true ? 'Yes' : 'No'),
            _buildDetailRow(
                "Is Active", userData['is_active'] == true ? 'Yes' : 'No'),
            _buildDetailRow("User Type", userData['user_type'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: logout,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Logout',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
