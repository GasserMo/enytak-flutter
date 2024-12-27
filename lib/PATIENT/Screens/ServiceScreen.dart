import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/ProviderDetailsScreen.dart';
import 'package:http/http.dart' as http;

class ServiceScreen extends StatefulWidget {
  final int categoryId;

  const ServiceScreen({required this.categoryId, Key? key}) : super(key: key);

  @override
  _ServiceScreenState createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  Map<String, dynamic>? categoryDetails;
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> subcategories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategoryDetails();
  }

  // Fetch category details
  Future<void> _fetchCategoryDetails() async {
    final categoryResponse = await http.get(
      Uri.parse('http://164.92.111.149/api/service-categories/'),
      headers: {
        'accept': 'application/json; charset=utf-8',
      },
    );
    if (categoryResponse.statusCode == 200) {
      final categories =
          json.decode(utf8.decode(categoryResponse.bodyBytes))['results'];

      // Find the category by categoryId
      final category = categories.firstWhere(
          (cat) => cat['id'] == widget.categoryId,
          orElse: () => null);

      if (category != null) {
        setState(() {
          categoryDetails = category;
          services.clear(); // Clear the services list before fetching new ones
        });
        print('Category: ${category}');
        print('category ids  +${category['service_ids'][0]['id']}');

        // If subcategory_ids is not null, fetch subcategory details
        List<dynamic> serviceIds =
            category['service_ids'].map((service) => service['id']).toList();

        // If subcategory_ids is not null, fetch subcategory details
        print('category sub ${category['subcategory_ids']}');
        if (category['subcategory_ids'] != null &&
            category['subcategory_ids'].isNotEmpty) {
          _fetchSubcategories(category['subcategory_ids']);
        } else {
          // Fetch services using all the extracted service_ids
          _fetchServices(serviceIds);
        }
      }
    }
  }

  // Fetch subcategories
  Future<void> _fetchSubcategories(List<dynamic> subcategoryIds) async {
    for (var subcategoryId in subcategoryIds) {
      final subcategoryResponse = await http.get(
        Uri.parse('http://164.92.111.149/api/subcategories/$subcategoryId/'),
        headers: {
          'accept': 'application/json; charset=utf-8',
        },
      );
      if (subcategoryResponse.statusCode == 200) {
        final subcategory =
            json.decode(utf8.decode(subcategoryResponse.bodyBytes));
        setState(() {
          subcategories.add(subcategory);
        });

        // After fetching subcategory, fetch its associated services
        _fetchServicesFromSubcategory(subcategory['service_ids']);
      }
    }
  }

  // Fetch services from subcategory
  Future<void> _fetchServicesFromSubcategory(List<dynamic> serviceIds) async {
    for (var serviceId in serviceIds) {
      final serviceResponse = await http.get(
        Uri.parse('http://164.92.111.149/api/services/$serviceId/'),
        headers: {
          'accept': 'application/json; charset=utf-8',
        },
      );
      if (serviceResponse.statusCode == 200) {
        final service = json.decode(utf8.decode(serviceResponse.bodyBytes));
        setState(() {
          services.add(service);
        });
      }
    }
  }

  // Fetch services from category directly
  Future<void> _fetchServices(List<dynamic> serviceIds) async {
    for (var serviceId in serviceIds) {
      final serviceResponse = await http.get(
        Uri.parse('http://164.92.111.149/api/services/$serviceId/'),
        headers: {
          'accept': 'application/json; charset=utf-8',
        },
      );
      if (serviceResponse.statusCode == 200) {
        final service = json.decode(utf8.decode(serviceResponse.bodyBytes));
        setState(() {
          services.add(service);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (categoryDetails == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${categoryDetails!['name'] ?? 'Unavailable'}'), // Display 'Unavailable' if the category name is null
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Name
              Text(
                '${categoryDetails!['name'] ?? 'Unavailable'}', // Handle null category name
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${categoryDetails!['description'] ?? 'Unavailable'}', // Handle null category description
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              // Subcategories Section
              if (subcategories.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Subcategories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ),
              if (subcategories.isNotEmpty)
                ...subcategories.map((subcategory) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      title: Text(
                        subcategory['name'] ??
                            'Unavailable', // Handle null subcategory name
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        subcategory['description'] ??
                            'Unavailable', // Handle null subcategory description
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Navigate to subcategory details if needed
                      },
                    ),
                  );
                }).toList(),

              // Services Section
              if (services.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ),
              if (services.isNotEmpty)
                ...services.map((service) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: service['image'] != null &&
                                service['image'].isNotEmpty
                            ? NetworkImage(service['image'])
                            : null, // Use the image if it's available
                        child: service['image'] == null ||
                                service['image'].isEmpty
                            ? const Icon(Icons.image,
                                size: 20, color: Colors.teal)
                            : null, // Show icon if no image is available// No child if there's a valid image
                      ),
                      title: Text(
                        service['name'] ??
                            'Unavailable', // Handle null service name
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        service['description'] ??
                            'Unavailable', // Handle null service description
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: Text(
                        '${service['price'] ?? 'N/A'} SAR', // Handle null service price
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      onTap: () {
                        // Navigate to the ProviderDetailsScreen when a service is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProviderDetailsScreen(
                              service:
                                  service, // Pass the service data to the new screen
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),

              // Fallback message when no services or subcategories are available
              if (services.isEmpty && subcategories.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No services or subcategories available for this category',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
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
