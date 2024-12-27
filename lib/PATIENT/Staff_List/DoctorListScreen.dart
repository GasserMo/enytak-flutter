import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/StaffDetails/doctor_details.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  _DoctorListScreenState createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  // Doctors list to hold fetched data
  late Future<List<Map<String, dynamic>>> doctors;

  @override
  void initState() {
    super.initState();
    doctors = fetchDoctors(); // Initialize the fetchDoctors call
  }

  // Fetch the list of doctors from the API
  Future<List<Map<String, dynamic>>> fetchDoctors() async {
    final url = Uri.parse('http://164.92.111.149/api/doctors/');
    final response = await http.get(
      url,
      headers: {
        'accept': 'application/json; charset=utf-8',
        'X-CSRFTOKEN':
            'TBnER2Sd30Nom2fNH40WwVJoMEWWyJsEEZNB4sXomfYXdTJIHJ7zFRNXr4BtC0EN',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final results = data['results'] as List;

      return results.map((doctor) {
        return {
          'id': doctor['id'],
          'user': doctor['user'] as int,
          'photo': doctor['personal_photo'] ?? 'assets/images/placeholder.png',
          'name': doctor['bio'] ?? 'Unknown Doctor',
          'specialization':
              doctor['specializations'].join(', ') ?? 'No specialization',
          'rating': doctor['average_rating'] ?? 0.0,
          'description': doctor['bio'] ?? 'No bio available',
        };
      }).toList();
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  // Save doctor ID in SharedPreferences
  Future<void> saveDoctorId(int doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('doctorId', doctorId);
  }

  // for (var doctor in results) {
  //   if (doctor['user'] != null) {
  //     await saveUserId(doctor['user']);
  //   }
  // }

  // // Save user ID in SharedPreferences
  // Future<void> saveUserId(int userdoctorId) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setInt('user', userdoctorId);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Top-Rated Doctors'),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: doctors, // Pass the fetched data here
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerEffect(); // Show shimmer effect
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching doctor data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No doctors available'));
          } else {
            final doctorsData = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two columns
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8, // Adjust this to change item height
                ),
                itemCount: doctorsData.length,
                itemBuilder: (context, index) {
                  final doctor = doctorsData[index];
                  return GestureDetector(
                    onTap: () async {
                      // Save doctor ID in SharedPreferences
                      await saveDoctorId(doctor['id']);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DoctorDetailsScreen(doctor: doctor),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Check if the photo URL exists or use the placeholder
                          CircleAvatar(
                            backgroundImage: doctor['photo']
                                    .toString()
                                    .contains('http')
                                ? NetworkImage(doctor['photo'])
                                : AssetImage(doctor['photo']) as ImageProvider,
                            radius: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            doctor['name'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            doctor['specialization'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Display the rating as stars or a numeric value
                              Icon(
                                Icons.star,
                                color: Colors.orange,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${doctor['rating']}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // You can display the price or any additional information
                          Text(
                            '\$${doctor['price'] ?? 'N/A'}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  // Shimmer effect for loading doctors
  Widget _buildShimmerEffect() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Two columns
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8, // Adjust this to change item height
        ),
        itemCount: 6, // Number of shimmer items
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: 100,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Container(
                        height: 14,
                        width: 30,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 14,
                    width: 60,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
