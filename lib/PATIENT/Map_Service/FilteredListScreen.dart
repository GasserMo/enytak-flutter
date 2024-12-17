import 'package:flutter/material.dart';

class FilteredListScreen extends StatefulWidget {
  const FilteredListScreen({
    super.key,
  });

  @override
  _FilteredListScreenState createState() => _FilteredListScreenState();
}

class _FilteredListScreenState extends State<FilteredListScreen> {
  String selectedDay = "Monday"; // Default selected day
  String selectedGender = "Any"; // Default gender filter

  // Mock data with gender attribute
  final List<Map<String, dynamic>> services = [
    {
      "name": "Service A",
      "schedule": "Morning",
      "day": "Monday",
      "image": "assets/images/capsules.png",
      "gender": "Male"
    },
    {
      "name": "Service B",
      "schedule": "Afternoon",
      "day": "Tuesday",
      "image": "assets/images/capsules.png",
      "gender": "Female"
    },
    {
      "name": "Service C",
      "schedule": "Evening",
      "day": "Wednesday",
      "image": "assets/images/capsules.png",
      "gender": "Any"
    },
    {
      "name": "Service D",
      "schedule": "Morning",
      "day": "Thursday",
      "image": "assets/images/capsules.png",
      "gender": "Male"
    },
    {
      "name": "Service E",
      "schedule": "Afternoon",
      "day": "Friday",
      "image": "assets/images/capsules.png",
      "gender": "Female"
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter services based on the selected day and gender
    final filteredServices = services
        .where((service) =>
            service["day"] == selectedDay &&
            (selectedGender == "Any" || service["gender"] == selectedGender))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Filtered Services"),
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Weekday Selector
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: Colors.teal.withOpacity(0.1),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (String day in [
                      "Monday",
                      "Tuesday",
                      "Wednesday",
                      "Thursday",
                      "Friday"
                    ])
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDay = day;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                            color:
                                selectedDay == day ? Colors.teal : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.teal),
                          ),
                          child: Text(
                            day,
                            style: TextStyle(
                              color: selectedDay == day
                                  ? Colors.white
                                  : Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Gender Filter
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Gender Filter Buttons
                  _buildGenderButton("Any"),
                  _buildGenderButton("Male"),
                  _buildGenderButton("Female"),
                ],
              ),
            ),

            // Filtered Services List
            Expanded(
              child: filteredServices.isEmpty
                  ? const Center(
                      child: Text(
                        "No services available for this day and gender.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredServices.length,
                      itemBuilder: (context, index) {
                        final service = filteredServices[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 5,
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                service["image"],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(service["name"]),
                            subtitle: Text("Schedule: ${service["schedule"]}"),
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

  // Function to build gender buttons
  Widget _buildGenderButton(String gender) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = gender;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: selectedGender == gender ? Colors.teal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.teal),
        ),
        child: Text(
          gender,
          style: TextStyle(
            color: selectedGender == gender ? Colors.white : Colors.teal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
