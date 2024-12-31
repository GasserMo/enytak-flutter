import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Appointment/AppointmentDetailsScreen.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/custom_AppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  String selectedStatus = 'booked'; // Default status
  List<dynamic> allAppointments = [];
  bool isLoading = true; // Show loading spinner during API call
  String errorMessage = ''; // To hold error messages

  // Status Choices (English Labels)
  final List<Map<String, String>> STATUS_CHOICES = [
    {'key': 'booked', 'label': 'Booked'},
    {'key': 'confirmed', 'label': 'Confirmed'},
    {'key': 'in_progress', 'label': 'In Progress'},
    {'key': 'completed', 'label': 'Completed'},
    {'key': 'dispatched', 'label': 'Dispatched'},
    {'key': 'delivered', 'label': 'Delivered'},
    {'key': 'cancelled', 'label': 'Cancelled'},
    {'key': 'pending', 'label': 'Pending'},
    {'key': 'rejected', 'label': 'Rejected'},
  ];

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 0;

      final response = await http.get(
        Uri.parse(
            'http://164.92.111.149/api/users/$userId/appointments/?page=1'),
        headers: {
          'accept': 'application/json; charset=utf-8',
          'X-CSRFTOKEN':
              'nBu98iMSXQUHWNabH8k7LLALqEPDzjQVmeBE9u7XssKYmYnL1hmvmJ8qRXOAfQ0u',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          allAppointments = data['results'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching appointments: $error';
      });
    }
  }

  List<dynamic> get filteredAppointments {
    return allAppointments
        .where((appointment) => appointment['status'] == selectedStatus)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.teal,
            ))
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Padding(
                  padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
                  child: Column(
                    children: [
                      // Toggle Buttons for Status
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: STATUS_CHOICES.map((status) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedStatus = status['key']!;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      selectedStatus == status['key']
                                          ? Colors.teal
                                          : Colors.grey[300],
                                ),
                                child: Text(
                                  status['label']!,
                                  style: TextStyle(
                                    color: selectedStatus == status['key']
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Appointments List
                      Expanded(
                        child: filteredAppointments.isEmpty
                            ? const Center(
                                child: Text('No appointments found.'),
                              )
                            : ListView.builder(
                                itemCount: filteredAppointments.length,
                                itemBuilder: (context, index) {
                                  final appointment =
                                      filteredAppointments[index];
                                  return GestureDetector(
                                    onTap: () {
                                      // Navigate to AppointmentDetailsScreen with necessary data
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AppointmentDetailsScreen(
                                              appointmentId: appointment['id'],
                                            ),
                                          ));
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 16),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // Placeholder for Doctor Photo
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.asset(
                                              'assets/images/appointment.png',
                                              height: 80,
                                              width: 60,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          // Appointment Details
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Service Type
                                                Text(
                                                  appointment['service_type'] ??
                                                      'N/A',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                // Date and Time
                                                Text(
                                                  appointment['date_time'] ??
                                                      'N/A',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                // Status
                                                Text(
                                                  appointment['status'] ??
                                                      'N/A',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.teal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
