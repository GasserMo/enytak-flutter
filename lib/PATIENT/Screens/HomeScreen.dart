import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/HOSPITAL/ServiceScreen.dart';
import 'package:flutter_sanar_proj/PATIENT/StaffDetails/doctor_details.dart';
import 'package:flutter_sanar_proj/PATIENT/StaffDetails/nurse_details.dart';
import 'package:flutter_sanar_proj/PATIENT/Staff_List/DoctorListScreen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_sanar_proj/PATIENT/Map_Service/GoogleMapScreen.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/custom_AppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

List<Map<String, dynamic>> serviceIcons = [
  {'id': 1, 'icon': Icons.local_hospital, 'name': 'Nursing Care'},
  {'id': 2, 'icon': Icons.medical_services, 'name': 'Doctor Visit'},
  {'id': 3, 'icon': Icons.spa, 'name': 'Physical Therapy'},
  {'id': 4, 'icon': Icons.person, 'name': 'Elderly Care'},
  {'id': 5, 'icon': Icons.child_care, 'name': 'Child Care'},
  {'id': 6, 'icon': Icons.cleaning_services, 'name': 'Cleaning Services'},
  {'id': 7, 'icon': Icons.delivery_dining, 'name': 'Meal Delivery'},
  {'id': 8, 'icon': Icons.home, 'name': 'Home Maintenance'},
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  IconData _getServiceIcon(int serviceId) {
    final iconEntry = serviceIcons.firstWhere(
      (entry) => entry['id'] == serviceId,
      orElse: () => {'icon': Icons.help_outline}, // Default icon if no match
    );
    return iconEntry['icon'] as IconData;
  }

  @override
  void initState() {
    super.initState();
    labsFuture = fetchTopRatedLabs();
  }

  // Fetch Services
  Future<List<Map<String, dynamic>>> fetchServicesCategories() async {
    final url = Uri.parse('http://164.92.111.149/api/service-categories/');
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

      return results.map((service) {
        return {
          'id': service['id'],
          'name': service['name'] ?? 'Unknown Service',
          'description': service['description'] ?? '',
          'image': service['image'] ?? '',
          'subcategory_ids': service['subcategory_ids'] ?? [],
          'service_ids': service['service_ids'] ?? [], // Service ids as objects
        };
      }).toList();
    } else {
      throw Exception('Failed to load services');
    }
  }

  late Future<List<Map<String, dynamic>>> labsFuture;

  Future<List<Map<String, dynamic>>> fetchServicesByIds(
      List<int> serviceIds) async {
    final List<Map<String, dynamic>> services = [];

    for (var service in serviceIds) {
      final serviceId = service; // Get the service id from the map
      final url = Uri.parse('http://164.92.111.149/api/services/$serviceId/');
      final response = await http.get(
        url,
        headers: {
          'accept': 'application/json',
          'X-CSRFTOKEN':
              'TBnER2Sd30Nom2fNH40WwVJoMEWWyJsEEZNB4sXomfYXdTJIHJ7zFRNXr4BtC0EN',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        services.add(data); // Add the response data to the services list
      }
    }

    return services;
  }

  // Fetch Doctors
  Future<List<Map<String, dynamic>>> fetchDoctors() async {
    final url = Uri.parse('http://164.92.111.149/api/doctors/');
    final response = await http.get(
      url,
      headers: {
        'accept': 'application/json',
        'X-CSRFTOKEN':
            'TBnER2Sd30Nom2fNH40WwVJoMEWWyJsEEZNB4sXomfYXdTJIHJ7zFRNXr4BtC0EN',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;

      // // Save the `user` field in SharedPreferences
      // for (var doctor in results) {
      //   if (doctor['user'] != null) {
      //     await saveUserId(doctor['user']);
      //   }
      // }

      return results.map((doctor) {
        return {
          'id': doctor['id'],
          'photo': doctor['personal_photo'] ?? 'assets/images/placeholder.png',
          'name': doctor['bio'] ?? 'Unknown Doctor',
          'specialization':
              doctor['specializations']?.join(', ') ?? 'No specialization',
          'rating': doctor['average_rating'] ?? 0.0,
          'description': doctor['bio'] ?? 'No bio available',
          'certifications':
              doctor['certifications'] ?? 'No certifications available',
          'years_of_experience':
              doctor['years_of_experience'] ?? 'Not provided',
          'city': doctor['city'] ?? 'Unknown City',
          'region': doctor['region'] ?? 'Unknown Region',
          'degree': doctor['degree'] ?? 'Not provided',
          'classification': doctor['classification'] ?? 'Not provided',
          'id_card_image':
              doctor['id_card_image'] ?? 'No ID card image available',
          'verification_status':
              doctor['verification_status'] ?? 'Not verified',
          'hospital': doctor['hospital'] ?? 'Not associated with a hospital',
          'services': doctor['services'] ?? [],
        };
      }).toList();
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  // Fetch Nurses
  Future<List<Map<String, dynamic>>> fetchNurses() async {
    final url = Uri.parse('http://164.92.111.149/api/nurses/');
    final response = await http.get(
      url,
      headers: {
        'accept': 'application/json',
        'X-CSRFTOKEN':
            'TBnER2Sd30Nom2fNH40WwVJoMEWWyJsEEZNB4sXomfYXdTJIHJ7zFRNXr4BtC0EN',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;

      return results.map((nurse) {
        return {
          'id': nurse['id'],
          'photo': nurse['personal_photo'] ?? 'assets/images/placeholder.png',
          'name': nurse['bio'] ?? 'Unknown Nurse',
          'specialization':
              nurse['specializations']?.join(', ') ?? 'No specialization',
          'rating': nurse['average_rating'] ?? 0.0,
          'description': nurse['bio'] ?? 'No bio available',
          'certifications':
              nurse['certifications'] ?? 'No certifications available',
          'years_of_experience': nurse['years_of_experience'] ?? 'Not provided',
          'city': nurse['city'] ?? 'Unknown City',
          'region': nurse['region'] ?? 'Unknown Region',
          'degree': nurse['degree'] ?? 'Not provided',
          'classification': nurse['classification'] ?? 'Not provided',
          'id_card_image':
              nurse['id_card_image'] ?? 'No ID card image available',
          'verification_status': nurse['verification_status'] ?? 'Not verified',
          'hospital': nurse['hospital'] ?? 'Not associated with a hospital',
          'services': nurse['services'] ?? [],
        };
      }).toList();
    } else {
      throw Exception('Failed to load nurses');
    }
  }

  Future<List<Map<String, dynamic>>> fetchHospitals() async {
    final url = Uri.parse('http://164.92.111.149/api/hospitals/');
    final response = await http.get(
      url,
      headers: {
        'accept': 'application/json',
        'X-CSRFTOKEN':
            'TBnER2Sd30Nom2fNH40WwVJoMEWWyJsEEZNB4sXomfYXdTJIHJ7zFRNXr4BtC0EN',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;

      return results.map((nurse) {
        return {
          'id': nurse['id'],
          'photo': nurse['personal_photo'] ?? 'assets/images/placeholder.png',
          'name': nurse['bio'] ?? 'Unknown Nurse',
          'specialization':
              nurse['specializations']?.join(', ') ?? 'No specialization',
          'rating': nurse['average_rating'] ?? 0.0,
          'description': nurse['bio'] ?? 'No bio available',
          'certifications':
              nurse['certifications'] ?? 'No certifications available',
          'years_of_experience': nurse['years_of_experience'] ?? 'Not provided',
          'city': nurse['city'] ?? 'Unknown City',
          'region': nurse['region'] ?? 'Unknown Region',
          'degree': nurse['degree'] ?? 'Not provided',
          'classification': nurse['classification'] ?? 'Not provided',
          'id_card_image':
              nurse['id_card_image'] ?? 'No ID card image available',
          'verification_status': nurse['verification_status'] ?? 'Not verified',
          'hospital': nurse['hospital'] ?? 'Not associated with a hospital',
          'services': nurse['services'] ?? [],
        };
      }).toList();
    } else {
      throw Exception('Failed to load nurses');
    }
  }

  Future<List<Map<String, dynamic>>> fetchTopRatedLabs() async {
    const String url = 'http://164.92.111.149/api/labs/';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json; charset=utf-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(utf8.decode(response.bodyBytes));

        // Extract the labs from the response
        final List labs = data['results'];

        // Filter for active labs with ratings > 0 and sort by average_rating (descending)
        final sortedLabs = labs
            .where((lab) =>
                lab['is_active'] == true && lab['average_rating'] != null)
            .toList()
          ..sort((a, b) => b['average_rating'].compareTo(a['average_rating']));

        return sortedLabs.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
            'Failed to fetch labs. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching labs: $e');
      return [];
    }
  }

  // Save doctor ID in SharedPreferences
  Future<void> saveDoctorId(int doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('doctorId', doctorId);
    print('Saved doctorID: $doctorId');
  }

  Future<void> saveNurseId(int nurseId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('nurseId', nurseId);
    print('Saved nurseID: $nurseId');
  }

// // Save user ID in SharedPreferences
  Future<void> saveServiceId(int serviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('serviceId', serviceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Homecare Services',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Map<String, dynamic>>>(
                // Services FutureBuilder
                future: fetchServicesCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildServiceShimmerEffect(); // Show shimmer effect
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text('Failed to load services',
                            style: TextStyle(color: Colors.red)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No services available'));
                  }

                  final services = snapshot.data!;
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 2.5,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return GestureDetector(
                        onTap: () async {
                          final categoryId =
                              service['id']; // The selected category ID
                          final serviceIds = service['service_ids'];

                          // Save the category ID to SharedPreferences
                          await saveServiceId(categoryId);
                          if (service['subcategory_ids'] == null ||
                              service['subcategory_ids'].isEmpty) {
                            // Extract just the IDs from service_ids (assuming it's a list of maps)
                            final ids = serviceIds
                                .map<int>((service) => service['id'] as int)
                                .toList();
                            print(ids);

                            // Fetch services by IDs
                            final services = await fetchServicesByIds(ids);

                            if (services.isNotEmpty) {
                              // Navigate to Service Screen and display the fetched services
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GoogleMapScreen(
                                    serviceIds: ids,
                                    categoryId: categoryId,
                                  ),
                                ),
                              );
                            } else {
                              // Show message if no services are found
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'No services available for this category.')),
                              );
                            }
                          } else {
                            // Navigate to Google Map Screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GoogleMapScreen(
                                  serviceIds: serviceIds,
                                  categoryId: categoryId,
                                ),
                              ),
                            );
                          }
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
                          child: Row(
                            children: [
                              Icon(
                                _getServiceIcon(service['id']),
                                size: 36,
                                color: Colors.teal,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  service['name'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Top-Rated Doctors',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorListScreen(),
                        ),
                      );
                    },
                    child: const Text('See All',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Map<String, dynamic>>>(
                // Doctors FutureBuilder
                future: fetchDoctors(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildDoctorShimmerEffect(); // Show shimmer effect
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text('Failed to load doctors',
                            style: TextStyle(color: Colors.red)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No top-rated doctors available'));
                  }

                  final doctors = snapshot.data!;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: doctors.map((doctor) {
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
                            margin: const EdgeInsets.only(right: 16),
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 5,
                                    spreadRadius: 2),
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(doctor['photo'],
                                      height: 90, width: 90, fit: BoxFit.cover),
                                ),
                                const SizedBox(height: 8),
                                Text(doctor['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(doctor['specialization'],
                                    style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text(doctor['rating'].toString(),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Top-Rated Nurses',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(

                      //     builder: (context) => NurseListScreen(),
                      //   ),
                      // );
                    },
                    child: const Text('See All',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Map<String, dynamic>>>(
                // Nurses FutureBuilder
                future: fetchNurses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildDoctorShimmerEffect(); // Show shimmer effect
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text('Failed to load nurses',
                            style: TextStyle(color: Colors.red)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No top-rated nurses available'));
                  }

                  final nurses = snapshot.data!;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: nurses.map((nurse) {
                        return GestureDetector(
                          onTap: () async {
                            // Save nurse ID in SharedPreferences
                            await saveNurseId(nurse['id']);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    NurseDetailsScreen(nurse: nurse),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 16),
                            width: 150,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 5,
                                    spreadRadius: 2),
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(nurse['photo'],
                                      height: 90, width: 90, fit: BoxFit.cover),
                                ),
                                const SizedBox(height: 8),
                                Text(nurse['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(nurse['specialization'],
                                    style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.amber, size: 16),
                                    const SizedBox(width: 4),
                                    Text(nurse['rating'].toString(),
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Top-Rated Labs',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  const SizedBox(height: 16),
                ],
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchTopRatedLabs(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildDoctorShimmerEffect(); // Show shimmer effect
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text(
                      'Failed to load labs',
                      style: TextStyle(color: Colors.red),
                    ));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No top-rated labs available',
                            style: TextStyle(color: Colors.grey)));
                  }

                  final labs = snapshot.data!;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: labs.map((lab) {
                        return GestureDetector(
                          onTap: () async {
                            // Handle lab click (e.g., navigate to details)
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 16),
                            width: 150,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Lab Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: lab['license_document'] != null
                                      ? Image.network(
                                          lab['license_document'],
                                          height: 90,
                                          width: 90,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          height: 90,
                                          width: 90,
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.image_not_supported,
                                            size: 40,
                                            color: Colors.teal,
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 8),
                                // Lab Name
                                Text(
                                  lab['name'] ?? 'Unnamed Lab',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // Lab Specialization

                                const SizedBox(height: 8),
                                // Lab Rating
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      lab['average_rating']
                                              ?.toStringAsFixed(1) ??
                                          '0.0',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Shimmer effect for services loading
  Widget _buildServiceShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.95,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4, // Number of shimmer items
        itemBuilder: (context, index) {
          return Container(
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
              children: [
                Container(
                  height: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 20,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Shimmer effect for doctors loading
  Widget _buildDoctorShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Row(
        children: List.generate(
          3,
          (index) => // Adjust the number of shimmer items
              Container(
            margin: const EdgeInsets.only(right: 16),
            width: 150,
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
              children: [
                Container(
                  height: 90,
                  width: 90,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 20,
                  width: double.infinity,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 20,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
