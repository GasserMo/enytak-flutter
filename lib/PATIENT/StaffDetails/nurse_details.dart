import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Schadule_Details/booking_Nurse_appointment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NurseDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> nurse;

  const NurseDetailsScreen({super.key, required this.nurse});

  // Save nurse ID to SharedPreferences
  Future<void> saveNurseId(int nurseId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('nurseId', nurseId);
    print('Saved nurseID: $nurseId');
  }

  // Retrieve nurse ID from SharedPreferences
  Future<int?> getNurseId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('nurseId');
  }

  Future<Map<String, dynamic>> fetchNurseDetails(int nurseId) async {
    final response = await http.get(
      Uri.parse('http://164.92.111.149/api/nurses/$nurseId/'),
      headers: {
        'accept': 'application/json',
        'X-CSRFTOKEN':
            'fZCw6KDoVfbnDDn0mCcGXcTZSPSyMCDneCJ17WYtqR1E3OAAGLe4yarEj8Rvs9NW',
      },
    );

    if (response.statusCode == 200) {
      print(nurseId);
      // Parse the nurse details from the response
      final nurseDetails = json.decode(response.body);

      // Extract the user ID from the response
      final int nurseUserId = nurseDetails['user'];

      // Store the user ID in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user', nurseUserId);

      // Return the nurse details
      return nurseDetails;
    } else {
      throw Exception('Failed to load nurse details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nurse['name']),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<int?>(
        future: getNurseId(), // Fetch nurse ID from SharedPreferences
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching nurse ID'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No nurse ID found'));
          } else {
            final nurseId = snapshot.data!;
            return FutureBuilder<Map<String, dynamic>>(
              future:
                  fetchNurseDetails(nurseId), // Fetch nurse details from API
              builder: (context, apiSnapshot) {
                if (apiSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (apiSnapshot.hasError) {
                  return const Center(
                      child: Text('Error fetching nurse details'));
                } else if (!apiSnapshot.hasData) {
                  return const Center(child: Text('No nurse details found'));
                } else {
                  final nurseDetails = apiSnapshot.data!;
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Image and Info Section
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Profile Image
                              Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(nurse['photo'] ?? ""),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Name and Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nurse['name'],
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      nurse['specialization'] ??
                                          'No specialization available',
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        RatingBox(
                                            rating:
                                                nurseDetails['average_rating']
                                                    .toString()),
                                        const SizedBox(width: 16),
                                        Row(
                                          children: [
                                            const Icon(Icons.attach_money,
                                                color: Colors.green),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Fee: ${nurse['fee']} SAR',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32, thickness: 1),

                          // Sections for additional data
                          _buildSection(
                              "Certifications", nurseDetails['certifications']),
                          _buildSection("Years of Experience",
                              nurseDetails['years_of_experience']?.toString()),
                          _buildSection("City", nurseDetails['city']),
                          _buildSection("Region", nurseDetails['region']),
                          _buildSection("Degree", nurseDetails['degree']),
                          _buildSection(
                              "Classification", nurseDetails['classification']),
                          _buildSection("Verification Status",
                              nurseDetails['verification_status']),
                          _buildSection("Specializations",
                              nurseDetails['specializations']?.join(', ')),
                          _buildSection(
                              "Services", nurseDetails['services']?.join(', ')),

                          // Nurse ID Section (from SharedPreferences)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Nurse ID",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  nurseId.toString(),
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),

                          // Buttons Section

                          // Buttons Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // Favorite Icon Button
                                IconButton(
                                  icon: const Icon(Icons.favorite_border,
                                      color: Colors.redAccent),
                                  onPressed: () {
                                    // Handle favorite action
                                  },
                                ),
                                // Book Video Appointment Button
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      backgroundColor: Colors.blueAccent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.video_call,
                                        color: Colors.white),
                                    label: const FittedBox(
                                      child: Text("Book Video\nAppointment",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white)),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ScheduleNurseScreen()),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Book Appointment Button
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      backgroundColor: Colors.green,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.person,
                                        color: Colors.white),
                                    label: const FittedBox(
                                      child: Text("Book\nAppointment",
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white)),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ScheduleNurseScreen()),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            );
          }
        },
      ),
      backgroundColor: Colors.white,
    );
  }
}

class RatingBox extends StatelessWidget {
  final String rating;

  const RatingBox({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        rating,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}

Widget _buildSection(String title, dynamic value) {
  if (value == null || (value is String && value.isEmpty)) {
    return const SizedBox();
  }
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    ),
  );
}
