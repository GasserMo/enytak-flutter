import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/HOSPITAL/Hospital_user_profile.dart';
import 'package:flutter_sanar_proj/LAB/lab_user_profile.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/custom_AppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: const Color(0xFFF8F9FA), // Subtle light background color
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Section
          _buildCard(
              child: GestureDetector(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final userType =
                  prefs.getString('user_type'); // Retrieve userType from prefs

              if (userType == 'hospital') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HospitalUserProfile()),
                );
              } else if (userType == 'lab') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LabUserProfile()),
                );
              } else {
                Navigator.pushNamed(
                    context, '/UserProfileScreen'); // Default route
              }
            },
            child: const Row(
              children: [
                // Removed the CircleAvatar and user name text
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'View Profile', // Only the View Profile text
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal),
                    ),
                  ],
                ),
                Spacer(),
                Icon(Icons.arrow_forward_ios, size: 20),
              ],
            ),
          )),

          const SizedBox(height: 16),

          // Language Selection Section
          _buildCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Language',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.teal,
                  ),
                ),
                DropdownButton<String>(
                  value:
                      'English', // Replace with selected language dynamically
                  items: <String>['English', 'Arabic']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    // Handle language change here
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // More Section
          _buildSectionCard(
            context,
            title: 'More',
            children: [
              _buildListTile(context, title: 'About', route: '/about'),
              _buildListTile(context,
                  title: 'Terms and Conditions', route: '/terms'),
              _buildListTile(context,
                  title: 'Privacy Policy', route: '/privacy'),
            ],
          ),

          const SizedBox(height: 16),

          // Work with Us Section
          _buildSectionCard(
            context,
            title: 'Work with Us',
            children: [
              _buildListTile(context,
                  title: 'Join Us', route: '/StaffSelectionScreen'),
            ],
          ),

          const SizedBox(height: 16),

          // Contact Section
          _buildSectionCard(
            context,
            title: 'Contact',
            children: [
              _buildListTile(context, title: 'Contact Us', route: '/contact'),
              _buildListTile(context,
                  title: 'Social Media', route: '/socialMedia'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context,
      {required String title, required String route}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 20),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}
