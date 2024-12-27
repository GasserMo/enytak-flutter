import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/AppointmentScreen.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/HomeScreen.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/LabAppointmentScreen.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/MedicalFilePage.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/SchedulePage.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/SettingPage.dart';

class LabMainScreen extends StatefulWidget {
  const LabMainScreen({super.key});

  @override
  State<LabMainScreen> createState() => _LabMainScreenState();
}

class _LabMainScreenState extends State<LabMainScreen> {
  int _currentIndex = 0; // Active tab index

  // List of screens to navigate between
  final List<Widget> _pages = [
    HomePage(),
    const LabAppointmentPage(),
    const SettingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Show the current active page
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update active tab index
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.time_to_leave),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}