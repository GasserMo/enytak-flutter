import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Map_Service/FilteredListScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ServiceDetailsScreen extends StatefulWidget {
  const ServiceDetailsScreen({Key? key}) : super(key: key);

  @override
  _ServiceDetailsScreenState createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  bool isLoading = true;
  bool hasError = false;
  Map<String, dynamic>? serviceData;
  int? serviceId;

  @override
  void initState() {
    super.initState();
    loadServiceId();
  }

  Future<void> loadServiceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedServiceId = prefs.getInt('serviceId');
      if (savedServiceId != null) {
        setState(() {
          serviceId = savedServiceId;
        });
        await fetchServiceDetails();
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> fetchServiceDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://164.92.111.149/api/services/$serviceId/'),
        headers: {
          'accept': 'application/json; charset=utf-8',
          'X-CSRFTOKEN':
              'bU7BqYWiamawqbj1jtuns2BsKzX58Arqaxe6rahnFY0NQmwBDCwL3097bSW2O7BZ',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          serviceData = json.decode(utf8.decode(response.bodyBytes));
          ;
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Loading..."),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal, Colors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError || serviceData == null || serviceId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Error"),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal, Colors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: const Center(
          child: Text("Failed to load service details. Please try again."),
        ),
      );
    }

    final name = serviceData!['name'] ?? "Service Name";
    final description =
        serviceData!['description'] ?? "No description available.";
    final price = serviceData!['price'] ?? "N/A";
    final imageUrl = serviceData!['image'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Service Details'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.green],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Price: \$${price.toString()}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FilteredListScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Proceed with Service',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
