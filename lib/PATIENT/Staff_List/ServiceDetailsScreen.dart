import 'package:flutter/material.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> service;

  const ServiceDetailsScreen({Key? key, required this.service})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Service Details',
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (service['image'] != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      service['image'],
                      width: screenWidth * 0.9,
                      height: screenHeight * 0.3,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                service['name'],
                style: TextStyle(
                  fontSize: screenWidth * 0.065,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              Divider(
                color: Colors.teal,
                thickness: 2,
                height: screenHeight * 0.03,
              ),
              Text(
                service['description'] ?? 'No description available',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Text(
                'Price: \$${service['price']}',
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Duration: ${service['duration']} minutes',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
