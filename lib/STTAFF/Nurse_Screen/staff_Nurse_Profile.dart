import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class Staff_Nurse_ProfileScreen extends StatefulWidget {
  const Staff_Nurse_ProfileScreen({super.key});

  @override
  _Staff_Nurse_ProfileScreenState createState() =>
      _Staff_Nurse_ProfileScreenState();
}

class _Staff_Nurse_ProfileScreenState extends State<Staff_Nurse_ProfileScreen> {
  late Future<Map<String, dynamic>> staffProfileFuture;
  String? token;
  int? specificId;
  int? userId;

  // Define the variables to hold the input values
  String bio = "";
  String certifications = "";
  int yearsOfExperience = 0;
  int averageRating = 5;
  String city = "";
  String region = "";
  String degree = "";
  String classification = "";

  File? _personalPhotoFile; // Add this to store the picked image file

  @override
  void initState() {
    super.initState();
    staffProfileFuture = fetchStaffProfile();
  }

  Future<Map<String, dynamic>> fetchStaffProfile() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access');
    specificId = prefs.getInt('specificId');

    final response = await http.get(
      Uri.parse('http://164.92.111.149/api/nurses/$specificId/'),
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load profile data');
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updatedData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      specificId = prefs.getInt('specificId');
      userId = prefs.getInt('userId') ?? 0;
      final token = prefs.getString('access');

      // Create a multipart request
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('http://164.92.111.149/api/nurses/$specificId/'),
      );

      // Add headers
      request.headers.addAll({
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Add text fields
      request.fields['bio'] = updatedData['bio'];
      request.fields['certifications'] = updatedData['certifications'];
      request.fields['years_of_experience'] =
          updatedData['years_of_experience'].toString();
      request.fields['average_rating'] =
          updatedData['average_rating'].toString();
      request.fields['city'] = updatedData['city'];
      request.fields['region'] = updatedData['region'];
      request.fields['degree'] = updatedData['degree'];
      request.fields['classification'] = updatedData['classification'];
      request.fields['user'] = userId.toString();

      // Add personal photo if a new one is selected
      if (updatedData['personal_photo'] != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'personal_photo',
          updatedData['personal_photo'],
        ));
      }

      // Send the request
      final response = await request.send();

      // Handle the response
      if (response.statusCode == 200) {
        print("Profile updated successfully");
        Fluttertoast.showToast(
          msg: "Profile updated successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.teal,
          textColor: Colors.white,
        );

        // Refresh the profile data
        setState(() {
          staffProfileFuture = fetchStaffProfile();
          _personalPhotoFile = null;
        });
      } else {
        final responseBody = await response.stream.bytesToString();
        print("Error updating profile: ${response.statusCode} - $responseBody");
        Fluttertoast.showToast(
          msg: "Failed to update profile",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      print("Error in updateProfile: $e");
      Fluttertoast.showToast(
        msg: "An error occurred",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // Method to pick an image from gallery or camera
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource
          .gallery, // You can change this to ImageSource.camera if needed
      maxWidth: 1800,
      maxHeight: 1800,
    );

    if (pickedFile != null) {
      setState(() {
        _personalPhotoFile = File(pickedFile.path);
      });
    }
  }

  // Method to show edit profile dialog
  void _showEditProfileDialog(Map<String, dynamic> data) {
    // Create controllers for all fields
    final TextEditingController bioController =
        TextEditingController(text: data['bio'] ?? "");
    final TextEditingController certificationsController =
        TextEditingController(text: data['certifications'] ?? "");
    final TextEditingController yearsOfExperienceController =
        TextEditingController(
            text: (data['years_of_experience'] ?? 0).toString());
    final TextEditingController averageRatingController =
        TextEditingController(text: (data['average_rating'] ?? 5).toString());
    final TextEditingController cityController =
        TextEditingController(text: data['city'] ?? "");
    final TextEditingController regionController =
        TextEditingController(text: data['region'] ?? "");
    final TextEditingController degreeController =
        TextEditingController(text: data['degree'] ?? "");
    final TextEditingController classificationController =
        TextEditingController(text: data['classification'] ?? "");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: const Text(
                "Edit Profile",
                style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile Photo Selection with Edit Icon
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _pickImage().then((_) {
                              // Update the dialog's state when image is picked
                              setState(() {});
                            });
                          },
                          child: CircleAvatar(
                            radius: 80,
                            backgroundColor: Colors.teal.withOpacity(0.2),
                            child: _personalPhotoFile != null
                                ? ClipOval(
                                    child: Image.file(
                                      _personalPhotoFile!,
                                      width: 160,
                                      height: 160,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : data['personal_photo'] != null
                                    ? ClipOval(
                                        child: Image.network(
                                          data['personal_photo'],
                                          width: 160,
                                          height: 160,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(
                                        Icons.camera_alt,
                                        size: 60,
                                        color: Colors.teal,
                                      ),
                          ),
                        ),
                        // Edit Icon Overlay
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.teal,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.white, size: 20),
                              onPressed: () {
                                _pickImage().then((_) {
                                  // Update the dialog's state when image is picked
                                  setState(() {});
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Text Fields
                    TextField(
                      controller: bioController,
                      decoration: InputDecoration(
                        labelText: "Bio",
                        labelStyle: const TextStyle(color: Colors.teal),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal),
                        ),
                      ),
                    ),
                    TextField(
                      controller: certificationsController,
                      decoration: InputDecoration(
                        labelText: "Certifications",
                        labelStyle: const TextStyle(color: Colors.teal),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal),
                        ),
                      ),
                    ),
                    TextField(
                      controller: yearsOfExperienceController,
                      decoration: InputDecoration(
                        labelText: "Years of Experience",
                        labelStyle: const TextStyle(color: Colors.teal),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: averageRatingController,
                      decoration: InputDecoration(
                        labelText: "Average Rating",
                        labelStyle: const TextStyle(color: Colors.teal),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: cityController,
                      decoration: InputDecoration(
                        labelText: "City",
                        labelStyle: const TextStyle(color: Colors.teal),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal),
                        ),
                      ),
                    ),
                    TextField(
                      controller: regionController,
                      decoration: InputDecoration(
                        labelText: "Region",
                        labelStyle: const TextStyle(color: Colors.teal),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal),
                        ),
                      ),
                    ),
                    TextField(
                      controller: degreeController,
                      decoration: InputDecoration(
                        labelText: "Degree",
                        labelStyle: const TextStyle(color: Colors.teal),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal),
                        ),
                      ),
                    ),
                    TextField(
                      controller: classificationController,
                      decoration: InputDecoration(
                        labelText: "Classification",
                        labelStyle: const TextStyle(color: Colors.teal),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Reset personal photo and close dialog
                    setState(() {
                      _personalPhotoFile = null;
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                  onPressed: () {
                    // Prepare the updated data
                    Map<String, dynamic> updatedData = {
                      "bio": bioController.text,
                      "certifications": certificationsController.text,
                      "years_of_experience":
                          int.tryParse(yearsOfExperienceController.text) ?? 0,
                      "average_rating":
                          int.tryParse(averageRatingController.text) ?? 5,
                      "city": cityController.text,
                      "region": regionController.text,
                      "degree": degreeController.text,
                      "classification": classificationController.text,
                      "personal_photo": _personalPhotoFile
                          ?.path, // Add the photo path if a new photo is selected
                    };

                    // Call the updateProfile method with the new data
                    updateProfile(updatedData);
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // This will be called when the dialog is dismissed
      setState(() {
        _personalPhotoFile = null;
      });
    });
  }

  Future<void> handleLogout() async {
    // Get the instance of SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Remove token and other saved data
    await prefs.remove('access');
    await prefs.remove('userId');
    await prefs.remove('specificId');
    await prefs.remove('user_type');

    // Show toast message
    Fluttertoast.showToast(
      msg: "Logged out successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.teal,
      textColor: Colors.white,
    );

    // Navigate to the login/signup screen
    Navigator.pushReplacementNamed(context, '/Login_Signup');

    print("User logged out successfully");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Map<String, dynamic>>(
        future: staffProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.teal,
                strokeWidth: 3,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return CustomScrollView(
              slivers: [
                // Custom App Bar
                SliverAppBar(
                  expandedHeight: 250.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      data['user'].toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background Image or Gradient
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.teal.shade400,
                                const Color.fromARGB(255, 160, 241, 211),
                              ],
                            ),
                          ),
                        ),
                        // Profile Photo
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 80,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 75,
                                  backgroundImage:
                                      data['personal_photo'] != null
                                          ? NetworkImage(data['personal_photo'])
                                          : const AssetImage(
                                                  'assets/images/doctor3.png')
                                              as ImageProvider,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Doctor',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Profile Content
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Personal Information Card
                      _buildProfileCard(
                        title: 'Personal Information',
                        children: [
                          _buildDetailRow('Native Language', 'English'),
                          _buildDetailRow('Country', data['region'] ?? 'N/A'),
                          _buildDetailRow('City', data['city'] ?? 'N/A'),
                        ],
                      ),

                      // Education Card
                      _buildProfileCard(
                        title: 'Education',
                        children: [
                          _buildDetailRow('Degree', data['degree'] ?? 'N/A'),
                          _buildDetailRow('Classification',
                              data['classification'] ?? 'N/A'),
                        ],
                      ),

                      // Experience Card
                      _buildProfileCard(
                        title: 'Experience',
                        children: [
                          _buildDetailRow('Years of Experience',
                              '${data['years_of_experience'] ?? 0} years'),
                          _buildDetailRow('Average Rating',
                              '${data['average_rating'] ?? 0} / 5'),
                        ],
                      ),

                      // Action Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _showEditProfileDialog(data),
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit Profile'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: handleLogout,
                              icon: const Icon(Icons.logout),
                              label: const Text('Logout'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade400,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('No data available'));
        },
      ),
    );
  }

  // Helper method to build profile cards
  Widget _buildProfileCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 4,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const Divider(color: Colors.teal),
            ...children,
          ],
        ),
      ),
    );
  }

  // Helper method to build detail rows
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
