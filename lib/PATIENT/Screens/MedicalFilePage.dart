import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/HOSPITAL/MedicalReports.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/custom_AppBar.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/MedicalFileDetails.dart';

class MedicalFilePage extends StatelessWidget {
  const MedicalFilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background color
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 20, horizontal: 16), // Adjust padding for better spacing
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Grid of medical files with customized card design
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio:
                      0.9, // Adjusted aspect ratio for better layout
                ),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return _buildMedicalFileItem(context, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalFileItem(BuildContext context, int index) {
    final items = [
      {'icon': Icons.check_circle, 'name': 'Lab Results'},
      {'icon': Icons.medical_services, 'name': 'Medicine Prescriptions'},
      {'icon': Icons.vaccines, 'name': 'Vaccination Reports'},
      {'icon': Icons.report_problem, 'name': 'Case Report'},
      {'icon': Icons.airline_seat_individual_suite, 'name': 'Sick Leave'},
      {'icon': Icons.assignment, 'name': 'My Programs'},
      {'icon': Icons.receipt_long, 'name': 'Medical Reports'},
      {'icon': Icons.person, 'name': 'Health Profile'},
      {'icon': Icons.fitness_center, 'name': 'Life Style'},
      {'icon': Icons.local_hospital, 'name': 'Insurance Approval'},
    ];

    final item = items[index];

    return Card(
      elevation: 10, // Increased elevation for a more prominent card
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(15), // Rounded corners for modern look
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          if (item['name'] == 'Medical Reports') {
            // Navigate to MedicalReportsPage when "Medical Reports" is clicked
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MedicalReportsPage(),
              ),
            );
          } else {
            // Navigate to MedicalFileDetails for other items
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MedicalFileDetails(
                  itemName: item['name'] as String,
                ),
              ),
            );
          }
        },
        splashColor: Colors.teal.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Circular icon with gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal, Colors.green],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                item['icon'] as IconData,
                color: Colors.white,
                size: 30, // Larger icons for better visibility
              ),
            ),
            const SizedBox(height: 10),
            // Text with larger font size and bold weight
            Text(
              item['name'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
