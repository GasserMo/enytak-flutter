import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleNurseScreen extends StatefulWidget {
  const ScheduleNurseScreen({super.key});

  @override
  _ScheduleNurseScreenState createState() => _ScheduleNurseScreenState();
}

class _ScheduleNurseScreenState extends State<ScheduleNurseScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  List<Map<String, dynamic>> availableSlots = []; // To hold available slots

  String? token; // To hold the token
  int? userId; // To hold the user ID
  int? nurseId; // To hold the doctor ID
  int? userNurseID; // To hold the doctor ID

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('access'); // Get token
      userId = prefs.getInt('userId'); // Get user ID
      nurseId = prefs.getInt('nurseId'); // Get doctor ID
      userNurseID = prefs.getInt('user'); // Get doctor ID
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load token, user ID, and doctor ID when the screen initializes
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
      availableSlots.clear(); // Clear previous slots
    });
    _fetchAvailableSlots(); // Fetch available slots for the selected date
  }

  Future<void> _fetchAvailableSlots() async {
    if (nurseId != null && selectedDate != null) {
      final String dayOfWeek =
          DateFormat('EEEE').format(selectedDate!).toLowerCase();
      final url = Uri.parse(
          'http://164.92.111.149/api/users/$userNurseID/availabilities/?page=1');

      try {
        final response = await http.get(url, headers: {
          'accept': 'application/json',
          'X-CSRFTOKEN':
              'P3FjABAEkWU1wc3ikUa0GKXXhY6nbXMgOGMOBNVJPyKiWngSE3cohIvCIh5kRuWP',
        });

        print(token);
        print(userId);
        print(nurseId);
        print(userNurseID);

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final results = data['results'] as List;

          print(token);
          print(userId);
          print(nurseId);
          print(userNurseID);

          // Filter available slots for the selected day
          availableSlots = results
              .where((slot) => slot['day_of_week'] == dayOfWeek)
              .cast<Map<String, dynamic>>()
              .toList();
          setState(() {}); // Update the UI
        } else {
          print('Failed to load available slots: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching available slots: $e');
      }
    }
  }

  void _onTimeSelected(TimeOfDay time) {
    setState(() {
      selectedTime = time;
    });
  }

  DateTime? get selectedDateTime {
    if (selectedDate != null && selectedTime != null) {
      return DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );
    }
    return null;
  }

  String? get formattedSelectedDate {
    if (selectedDate != null) {
      return DateFormat('yyyy-MM-dd').format(selectedDate!); // Format date
    }
    return null;
  }

  String? get formattedSelectedTime {
    if (selectedTime != null) {
      return '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00'; // Format time with timezone
    }
    return null;
  }

  Future<void> _onBookAppointment() async {
    if (selectedDate != null &&
        selectedTime != null &&
        token != null &&
        userId != null &&
        nurseId != null) {
      // Use values retrieved from shared preferences
      final int patientId = userId!; // Use the user ID
      final int NureeId = nurseId!; // Use the doctor ID
      final int serviceId = 4; // Ensure this is a valid service ID

      // Include additional fields as per the cURL request
      final appointmentData = {
        "date_time": selectedDateTime
            ?.toIso8601String(), // Format the selected date-time
        "service_type": "teleconsultation",
        "status": "booked",
        "notes": "string", // You can replace with actual notes if needed
        "appointment_address": "string", // Address for the appointment
        "is_follow_up": false, // Example follow-up value
        "is_confirmed": false, // Example confirmation value
        "patient": patientId, // Use the user ID
        "doctor": null, // Use the doctor ID
        "nurse": NureeId, // Set to null if not required
        "services": [serviceId], // Ensure this is a valid service ID
      };

      // Print userId, patientId, and date_time for debugging
      print('User ID: $userId');
      print('Patient ID: $patientId');
      print('Date Time: ${selectedDateTime?.toIso8601String()}');
      print('Services: $userId');

      try {
        final response = await http.post(
          Uri.parse('http://164.92.111.149/api/appointments/'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-CSRFTOKEN':
                'o0Y2YK8sS1VKe1pNcJlrvZ8Gs6Jrf28nnD5xZWtxnDL1EcCnwSnP6XGlTpIoVziW', // Use the correct CSRF token
            'Authorization': 'Bearer $token', // Use the token for authorization
          },
          body: json.encode(appointmentData), // Send the appointment data
        );

        // Print the status code and response body
        print('Response Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        // Handle the response
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment successfully booked!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Decode and print error message from response body
          final responseBody = json.decode(response.body);
          print('Error Response Body: $responseBody');

          String errorMessage =
              'Failed to book appointment. Please try again later';
          // if (responseBody['patient'] != null) {
          //   errorMessage += '\nInvalid patient.';
          // }
          // if (responseBody['doctor'] != null) {
          //   errorMessage += '\nInvalid doctor.';
          // }
          // if (responseBody['date_time'] != null) {
          //   errorMessage += '\nInvalid date/time.';
          // }
          // Print the complete error message and status code
          print('Error Message: $errorMessage');
          print('Status Code: ${response.statusCode}');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$errorMessage'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Print the error stack trace
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Failed to book appointment. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please fill in all the details to book an appointment'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Appointment"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Select Appointment Date",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (picked != null && picked != selectedDate) {
                  _onDateSelected(picked); // Call the date selected method
                }
              },
              child: Card(
                elevation: 5,
                color:
                    selectedDate == null ? Colors.grey[300] : Colors.teal[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Text(
                      selectedDate == null
                          ? 'Select Date'
                          : DateFormat('yMMMd').format(selectedDate!),
                      style: TextStyle(
                        color: selectedDate == null
                            ? Colors.black
                            : Colors.teal[800],
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Select Appointment Time",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
            const SizedBox(height: 10),
            // Display available times based on selected date
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: availableSlots.length,
              itemBuilder: (context, index) {
                final slot = availableSlots[index];
                final startTime = TimeOfDay(
                  hour: int.parse(slot['start_time'].split(':')[0]),
                  minute: int.parse(slot['start_time'].split(':')[1]),
                );
                // final endTime = TimeOfDay(
                //   hour: int.parse(slot['end_time'].split(':')[0]),
                //   minute: int.parse(slot['end_time'].split(':')[1]),
                // );

                return GestureDetector(
                  onTap: () =>
                      _onTimeSelected(startTime), // Select the start time
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: selectedTime == startTime
                          ? Colors.teal
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        if (selectedTime == startTime)
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.4),
                            spreadRadius: 3,
                            blurRadius: 6,
                          )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${startTime.format(context)}', // - ${endTime.format(context)}'
                        style: TextStyle(
                          color: selectedTime == startTime
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _onBookAppointment,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Book Appointment',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
