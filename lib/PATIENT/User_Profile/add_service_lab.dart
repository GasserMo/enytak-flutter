import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LabAddService extends StatefulWidget {
  const LabAddService({super.key});

  @override
  State<LabAddService> createState() => _AddServiceState();
}

class _AddServiceState extends State<LabAddService> {
  Map<String, dynamic> labData = {};
  String? token;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  int? selectedCategory; // Store selected category ID

  Map<String, int> categoryMap = {
    'Homevisit': 4,
    'Laboratory': 5,
    'Seasonal Flu Vaccination': 3,
    'Radiology': 0,
    'Nursing Services': 2,
    'Kids Vaccination': 6,
    'استرخاء': 7,
  };

  bool isLoading = false; // For loading state

  @override
  void initState() {
    super.initState();
    fetchLab();
  }

  int? labId;
  Future<void> fetchLab() async {
    setState(() {
      isLoading = true; // Set loading state true
    });

    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access');
    labId = prefs.getInt('specificId'); // Fetch hospital ID

    if (token == null || labId == null) {
      _showErrorSnackBar("No token or hospital ID found. Please login first.");
      setState(() {
        isLoading = false;
      });
      return;
    }

    final String apiUrl = 'http://164.92.111.149/api/labs/$labId/';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          labData = json.decode(utf8.decode(response.bodyBytes));
        });

        // Fetch doctor and nurse details

        fetchCategories();
      } else {
        _showErrorSnackBar('Error fetching hospital data.');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load hospital data: $e');
    } finally {
      setState(() {
        isLoading = false; // Set loading state false after fetching data
      });
    }
  }

  Future<void> fetchUserDetails(
      int userId, List<Map<String, dynamic>> fetchedList) async {
    final String userApiUrl = 'http://164.92.111.149/api/users/$userId/';

    try {
      final response = await http.get(
        Uri.parse(userApiUrl),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        String userName = userData['full_name'] ?? 'No Name';

        fetchedList.add({'id': userId, 'name': userName});
      } else {
        fetchedList
            .add({'id': userId, 'name': 'Error: Unable to fetch user data'});
      }
    } catch (e) {
      fetchedList.add({'id': userId, 'name': 'Failed to load user data'});
    }
  }

  List<Map<String, dynamic>> categories = []; // Store categories

  Future<void> fetchCategories() async {
    final String categoriesApiUrl =
        'http://164.92.111.149/api/service-categories/';

    try {
      final response = await http.get(
        Uri.parse(categoriesApiUrl),
        headers: {
          'accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          categories = List<Map<String, dynamic>>.from(data['results']);
        });
      } else {
        _showErrorSnackBar('Error fetching categories.');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load categories: $e');
    }
  }

  Future<void> createService(
    String name,
    String price,
    String duration,
    int category,
  ) async {
    final String apiUrl = 'http://164.92.111.149/api/services/';

    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type':
          'application/json', // Ensure Content-Type is set to application/json
    };

    final body = json.encode({
      'name': name,
      'description': descriptionController.text.isNotEmpty
          ? descriptionController.text
          : null, // Optional field, can be null
      'price': price,
      'duration': duration,
      'category': category,
      'labs': [labId],
      'doctors': [], // List of doctor IDs
      'nurses': [], // List of nurse IDs
      'hospitals': [], // List of hospital IDs
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201) {
        Fluttertoast.showToast(msg: "Service added successfully");
        print(response.body);
      } else {
        Fluttertoast.showToast(msg: "Failed to add service: ${response.body}");
        print(response.body);
        print(response.statusCode);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Service'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(
                child:
                    CircularProgressIndicator()) // Show loading spinner while data loads
            : ListView(
                children: [
                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'Service Name'),
                  ),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price'),
                  ),
                  TextField(
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Duration (minutes)'),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  DropdownButton<int>(
                    hint: const Text('Select Category'),
                    value: selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                    items: categories
                        .map((category) => DropdownMenuItem<int>(
                              value: category['id'],
                              child: Text(category['name']),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isEmpty ||
                          priceController.text.isEmpty ||
                          durationController.text.isEmpty ||
                          selectedCategory == null) {
                        _showErrorSnackBar("Please fill all fields");
                      } else {
                        createService(
                          nameController.text,
                          priceController.text,
                          durationController.text,
                          selectedCategory!,
                        );
                      }
                    },
                    child: const Text('Add Service'),
                  ),
                ],
              ),
      ),
    );
  }
}
