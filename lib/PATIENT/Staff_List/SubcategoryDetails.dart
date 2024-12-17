import 'package:flutter/material.dart';

class SubcategoryDetails extends StatelessWidget {
  final Map<String, dynamic> subcategory;

  const SubcategoryDetails({Key? key, required this.subcategory})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          ('Subcategory Details'),
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
              if (subcategory['image'] != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      subcategory['image'],
                      width: screenWidth * 0.9,
                      height: screenHeight * 0.3,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                subcategory['name'],
                style: TextStyle(
                  fontSize: screenWidth * 0.08,
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
                subcategory['description'] ?? 'No description available',
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Text(
                'Services:',
                style: TextStyle(
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: subcategory['services'].length,
                itemBuilder: (context, index) {
                  final service = subcategory['services'][index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: Row(
                        children: [
                          Icon(
                            Icons.medical_services,
                            size: screenWidth * 0.1,
                            color: Colors.teal,
                          ),
                          SizedBox(width: screenWidth * 0.04),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service['name'],
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.005),
                                Text(
                                  service['description'] ??
                                      'No description available',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    color: Colors.grey[600],
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
            ],
          ),
        ),
      ),
    );
  }
}
