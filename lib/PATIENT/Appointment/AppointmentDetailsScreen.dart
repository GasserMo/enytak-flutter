import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AppointmentDetailsScreen extends StatefulWidget {
  final int appointmentId;

  const AppointmentDetailsScreen({super.key, required this.appointmentId});

  @override
  _AppointmentDetailsScreenState createState() =>
      _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  late Map<String, dynamic> scheduleData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointmentDetails();
  }

  Future<void> _fetchAppointmentDetails() async {
    final url =
        'http://164.92.111.149/api/appointments/${widget.appointmentId}';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'accept': 'application/json',
        'X-CSRFTOKEN':
            'XTUxdmxFdvqlHzXUKrrrT9itDG3fOvo6Ww12eySKI7gC7Kau4AtPu7Q84Z2cu2yF',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        scheduleData = json.decode(response.body);
        isLoading = false;
      });
    } else {
      // Handle error here
      setState(() {
        isLoading = false;
      });
      // You could show an error message to the user.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Appointment Details'),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.teal,
            )) // Loading indicator
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Appointment Information Section
                  _buildSectionTitle('Appointment Info'),
                  _buildCardInfo(
                      'Appointment ID', scheduleData['id'].toString()),
                  _buildCardInfo(
                      'Day', scheduleData['date_time'] ?? 'Not Available'),
                  _buildCardInfo(
                      'Time', scheduleData['date_time'] ?? 'Not Available'),

                  const SizedBox(height: 24),

                  // Patient & Service Information Section
                  _buildSectionTitle('Patient & Service Info'),
                  _buildCardInfo('Patient',
                      scheduleData['patientName'] ?? 'Not Available'),
                  _buildCardInfo('Service',
                      scheduleData['service_type'] ?? 'Not Available'),
                  _buildCardInfo(
                      'Price', '\$${scheduleData['cost'] ?? '0.00'}'),

                  const SizedBox(height: 24),

                  // Location Section (City, Street as Subtitle)
                  _buildSectionTitle('Location'),
                  _buildLocationInfo('City',
                      scheduleData['appointment_address'] ?? 'Not Available'),
                  _buildLocationInfo(
                      'Street', 'Not Available'), // Replace accordingly
                  _buildLocationInfo(
                      'Other', 'Not Available'), // Replace accordingly

                  const SizedBox(height: 24),

                  // Doctor Details Section
                  _buildSectionTitle('Doctor Info'),
                  _buildDoctorCard(scheduleData),

                  const SizedBox(height: 32),

                  // Cancel Appointment Button
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _cancelAppointment(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 50),
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                      ),
                      child: const Text(
                        'Cancel Appointment',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }

  Widget _buildCardInfo(String label, String info) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              info,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(String subtitle, String info) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 40,
            color: Colors.teal,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                info,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> scheduleData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/appointment.png', // Replace with actual doctor image
              height: 120,
              width: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dr. ${scheduleData['doctor'] ?? 'Not Available'}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                scheduleData['specialization'] ?? 'Not Available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ],
      ),
    );
  }

  void _cancelAppointment(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Appointment'),
          content:
              const Text('Are you sure you want to cancel this appointment?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Appointment Cancelled')),
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
