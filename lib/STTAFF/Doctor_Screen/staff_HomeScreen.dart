import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/STTAFF/Doctor_Screen/staff_addService.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/custom_AppBar.dart';
import 'package:shimmer/shimmer.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  _StaffHomeScreenState createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  Map<String, dynamic>? staffProfile;
  List<Map<String, dynamic>> upcomingAppointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStaffProfile();
    fetchConfirmedAppointments();
  }

  Future<void> fetchStaffProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access');
      final specificId = prefs.getInt('specificId');

      final response = await http.get(
        Uri.parse('http://164.92.111.149/api/doctors/$specificId/'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          staffProfile = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load profile data');
      }
    } catch (error) {
      print('Error fetching staff profile: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchConfirmedAppointments() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access') ?? '';
    // final doctorId = prefs.getInt('doctorId') ?? 0;
    final specificId = prefs.getInt('specificId');

    final url =
        'http://164.92.111.149/api/doctors/$specificId/appointments/?page=1';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'X-CSRFTOKEN':
              'nBu98iMSXQUHWNabH8k7LLALqEPDzjQVmeBE9u7XssKYmYnL1hmvmJ8qRXOAfQ0u',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('HTTP Response Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Parsed Data: $data');

        final results = List<Map<String, dynamic>>.from(data['results']);

        // Filter confirmed appointments
        setState(() {
          upcomingAppointments = results
              .where((appointment) => appointment['status'] == 'confirmed')
              .toList();
        });

        debugPrint('Filtered Confirmed Appointments: $upcomingAppointments');
      } else {
        debugPrint('Error Response: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.teal,
              ),
            )
          : staffProfile == null
              ? Center(
                  child: Text(
                    'Failed to load profile data.',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : Column(
                  children: [
                    // Header Section
                    SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'ID: ${staffProfile!['id']}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Specialization: ${staffProfile!['classification'] ?? 'Not Specified'}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'City: ${staffProfile!['city'] ?? 'Not Specified'}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ClipOval(
                              child: staffProfile!['personal_photo'] != null
                                  ? Image.network(
                                      staffProfile!['personal_photo'],
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.1,
                                      width:
                                          MediaQuery.of(context).size.height *
                                              0.1,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/images/capsules.png',
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.1,
                                      width:
                                          MediaQuery.of(context).size.height *
                                              0.1,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    // Add Service Button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StaffAddservice()),
                          );
                        },
                        icon: const Icon(Icons.add, color: Colors.black),
                        label: const Text(
                          'Add Service',
                          style: TextStyle(color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Upcoming Appointments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (isLoading)
                      Expanded(
                        child: ListView.builder(
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                elevation: 4,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                      color: Colors.teal, width: 1),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  title: Container(
                                    width: double.infinity,
                                    height: 16.0,
                                    color: Colors.white,
                                  ),
                                  subtitle: Container(
                                    width: double.infinity,
                                    height: 14.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else if (upcomingAppointments.isEmpty)
                      const Center(
                        child: Text('No upcoming confirmed appointments.'),
                      )
                    else
                      Expanded(
                        child: AnimatedList(
                          initialItemCount: upcomingAppointments.length,
                          itemBuilder: (context, index, animation) {
                            final appointment = upcomingAppointments[index];
                            return SlideTransition(
                              position: animation.drive(
                                Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).chain(CurveTween(curve: Curves.easeInOut)),
                              ),
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                elevation: 4,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                      color: Colors.teal, width: 1),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  title: Text(
                                    'Appointment ID: ${appointment['id']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Date: ${appointment['date_time']}\nService Type: ${appointment['service_type']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.arrow_forward,
                                        color: Colors.teal),
                                    onPressed: () {
                                      // Navigate to the appointment details page if needed
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
    );
  }
}
