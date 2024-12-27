import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Schadule_Details/booking_Doctor_appointment.dart';
import 'package:flutter_sanar_proj/PATIENT/Schadule_Details/booking_Nurse_appointment.dart';
import 'package:flutter_sanar_proj/PATIENT/Schadule_Details/booking_hospital.dart';
import 'package:flutter_sanar_proj/PATIENT/Schadule_Details/booking_lab.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/userDetails.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Colors/colors.dart';
import 'package:http/http.dart' as http;

class ProviderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> service;

  const ProviderDetailsScreen({required this.service, Key? key})
      : super(key: key);

  @override
  _ProviderDetailsScreenState createState() => _ProviderDetailsScreenState();
}

class _ProviderDetailsScreenState extends State<ProviderDetailsScreen> {
  List<Map<String, dynamic>> doctors = [];
  List<Map<String, dynamic>> nurses = [];
  List<Map<String, dynamic>> hospitals = [];
  List<Map<String, dynamic>> labs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProviders();
  }

  // Fetch doctors, nurses, and hospitals based on service provider_info
  Future<void> _fetchProviders() async {
    // Set loading state to true
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch doctors, nurses, labs, and hospitals concurrently using Future.wait
      await Future.wait([
        _fetchDoctors(),
        _fetchLabs(),
        _fetchNurses(),
        _fetchHospitals(),
      ]);
    } catch (e) {
      print('Error fetching providers: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchDoctors() async {
    for (var doctorId in widget.service['doctors']) {
      final doctorResponse = await http
          .get(Uri.parse('http://164.92.111.149/api/doctors/$doctorId/'));
      if (doctorResponse.statusCode == 200) {
        final doctor = jsonDecode(doctorResponse.body);

        // Fetch user details for the doctor
        final userResponse = await http.get(
            Uri.parse('http://164.92.111.149/api/users/${doctor['user']}/'));
        if (userResponse.statusCode == 200) {
          final user = jsonDecode(userResponse.body);
          doctor['userDetails'] = user; // Add user details to doctor data
        }

        setState(() {
          doctors.add(doctor);
        });
      }
    }
  }

  Future<void> _fetchLabs() async {
    for (var labId in widget.service['labs']) {
      final labsResponse =
          await http.get(Uri.parse('http://164.92.111.149/api/labs/$labId/'));
      if (labsResponse.statusCode == 200) {
        final lab = jsonDecode(labsResponse.body);

        // Fetch user details for the lab
        final userResponse = await http
            .get(Uri.parse('http://164.92.111.149/api/users/${lab['user']}/'));
        if (userResponse.statusCode == 200) {
          final user = jsonDecode(userResponse.body);
          lab['userDetails'] = user; // Add user details to lab data
        }

        setState(() {
          labs.add(lab);
        });
      }
    }
  }

  Future<void> _fetchNurses() async {
    for (var nurseId in widget.service['nurses']) {
      final nurseResponse = await http
          .get(Uri.parse('http://164.92.111.149/api/nurses/$nurseId/'));
      if (nurseResponse.statusCode == 200) {
        final nurse = jsonDecode(nurseResponse.body);

        // Fetch user details for the nurse
        final userResponse = await http.get(
            Uri.parse('http://164.92.111.149/api/users/${nurse['user']}/'));
        if (userResponse.statusCode == 200) {
          final user = jsonDecode(userResponse.body);
          nurse['userDetails'] = user; // Add user details to nurse data
        }

        setState(() {
          nurses.add(nurse);
        });
      }
    }
  }

  Future<void> _fetchHospitals() async {
    for (var hospitalId in widget.service['hospitals']) {
      final hospitalResponse = await http
          .get(Uri.parse('http://164.92.111.149/api/hospitals/$hospitalId/'));
      if (hospitalResponse.statusCode == 200) {
        final hospital = jsonDecode(hospitalResponse.body);

        // Fetch user details for the hospital
        final userResponse = await http.get(
            Uri.parse('http://164.92.111.149/api/users/${hospital['user']}/'));
        if (userResponse.statusCode == 200) {
          final user = jsonDecode(userResponse.body);
          hospital['userDetails'] = user; // Add user details to hospital data
        }

        setState(() {
          hospitals.add(hospital);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasHospital = hospitals.isNotEmpty;
    bool hasLab = labs.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service['name']),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.service['image'] != null)
              Center(
                child: ClipOval(
                  child: Image.network(
                    widget.service['image'],
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(
                    Icons.image_not_supported,
                    size: 60,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Description
            Text(
              'Description: ${widget.service['description'] ?? 'No description available'}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.teal.shade700,
              ),
            ),
            const SizedBox(height: 16),

            // Price
            Text(
              'Price: ${widget.service['price']} SAR',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.teal.shade600,
              ),
            ),
            const SizedBox(height: 16),

            // Duration
            Text(
              'Duration: ${widget.service['duration']}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Status (active or not)
            Text(
              'Status: ${widget.service['is_active'] == true ? 'Active' : 'Inactive'}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: widget.service['is_active'] == true
                    ? Colors.green.shade600
                    : Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 16),

            /* _buildProviderSection('Doctors', doctors, 'doctor'),
            _buildProviderSection('Nurses', nurses, 'nurse'), */
            /* _buildProviderSection('Hospitals', hospitals, 'hospital'),
            _buildProviderSection('labs', labs, 'lab'), */

            // Check if hospital or lab providers exist

            if (widget.service['hospitals'].isNotEmpty &&
                widget.service['labs'].isEmpty)
              _buildProviderSection('Hospitals', hospitals, 'hospital'),
            if (widget.service['labs'].isNotEmpty &&
                widget.service['hospitals'].isEmpty)
              _buildProviderSection('Labs', labs, 'lab'),
            if (widget.service['labs'].isEmpty &&
                widget.service['hospitals'].isEmpty &&
                widget.service['doctors'].isNotEmpty)
              _buildProviderSection('Doctors', doctors, 'doctor'),
            if (widget.service['labs'].isEmpty &&
                widget.service['hospitals'].isEmpty &&
                widget.service['nurses'].isNotEmpty)
              _buildProviderSection('Nurses', nurses, 'nurse'),

            // Show both if both exist
          ],
        ),
      ),
    );
  }

  Widget _buildProviderSection(
      String title, List<Map<String, dynamic>> providers, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
        ),
        SizedBox(height: 8),
        // Providers List
        if (providers.isNotEmpty)
          ...providers.map((provider) {
            final user = provider['userDetails'] ?? {};
            final id = provider['id']; // Ensure we have the provider's id
            final type = user['user_type'];
            final profileImageUrl =
                user['profile_image']; // Get the profile image URL

            return Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar and Name Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Avatar
                        profileImageUrl != null && profileImageUrl.isNotEmpty
                            ? CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(profileImageUrl),
                              )
                            : CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.teal,
                                child: Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.white,
                                ),
                              ),
                        SizedBox(width: 16),
                        // Provider Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Full Name with View Profile
                              Row(
                                children: [
                                  // User Name
                                  Text(
                                    user['full_name'] ?? 'No name available',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              UserDetailsScreen(
                                            user: user,
                                            provider:
                                                provider, // Pass the full provider details
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'View Profile',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: primaryColor,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              // Price
                              Text(
                                'Price: ${widget.service['price']} SAR',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.teal.shade600,
                                ),
                              ),
                              SizedBox(height: 4),
                              // User Type (Doctor, Nurse, etc.)
                              Text(
                                user['user_type'] ?? 'No user type available',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 8),
                              // Contact Info
                              Text(
                                user['email'] ?? 'No email available',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                user['phone_number'] ??
                                    'No phone number available',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Book Appointment Button
                    GestureDetector(
                      onTap: () {
                        // Navigate based on provider type
                        if (type == 'doctor') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScheduleScreen(
                                  // Pass doctor id
                                  ),
                            ),
                          );
                        } else if (type == 'nurse') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScheduleNurseScreen(
                                  // Pass nurse id
                                  ),
                            ),
                          );
                        } else if (type == 'hospital') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScheduleHospitalScreen(
                                price: widget.service['price'],
                                userId: provider['user'],
                                hospitalId: provider['id'],
                                serviceId: widget.service['id'],
                              ),
                            ),
                          );
                        } else if (type == 'lab') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScheduleLabScreen(
                                price: widget.service['price'],
                                userId: provider['user'],
                                labId: provider['id'],
                                serviceId: widget.service['id'],
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Book Appointment',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        if (_isLoading)
          Center(
              child: CircularProgressIndicator(
            color: primaryColor,
          )),
        if (providers.isEmpty && !_isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'No $type available for this service.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}

extension StringCapitalization on String {
  String get capitalize =>
      this.isEmpty ? this : '${this[0].toUpperCase()}${this.substring(1)}';
}
