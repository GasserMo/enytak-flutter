import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Login-Signup/Login-Signup/login.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_sanar_proj/PATIENT/Login-Signup/Login-Signup/login_signup.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Colors/colors.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/CustomInputField.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
// import 'medicalRegistration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalRegistrationPage extends StatefulWidget {
  const PersonalRegistrationPage({super.key});

  @override
  _PersonalRegistrationPageState createState() =>
      _PersonalRegistrationPageState();
}

class _PersonalRegistrationPageState extends State<PersonalRegistrationPage> {
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _addressController = TextEditingController();
  DateTime? _birthDate;
  String? _profilePhoto = '';
  String? _selectedGender;
  String? _selectedUserType;

  String? file_Type;
  PlatformFile? selectedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        selectedFile = file;
        _profilePhoto = file.path;
      });
      print('Selected file: ${file.path}');
    }
  }

  Map<String, String?> _errors = {
    "username": null,
    "full_name": null,
    "email": null,
    "phone": null,
    "password": null,
    "gender": null,
    "confirm_password": null,
  };
  String? token;
  Future<void> _submitDetails(PlatformFile file) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access'); // Get token
    setState(() {
      // Clear previous errors
      _errors = {
        "username": null,
        "full_name": null,
        "email": null,
        "phone": null,
        "password": null,
        "confirm_password": null,
      };
    });

    bool isValid = true;

    // Validate Username
    if (_usernameController.text.isEmpty) {
      _errors["username"] = "Username is required";
      isValid = false;
    }

    // Validate Full Name
    if (_fullNameController.text.isEmpty) {
      _errors["full_name"] = "Full Name is required";
      isValid = false;
    }

    // Validate Email
    if (_emailController.text.isEmpty) {
      _errors["email"] = "Email is required";
      isValid = false;
    }

    // Validate Phone
    if (_phoneController.text.isEmpty) {
      _errors["phone"] = "Phone number is required";
      isValid = false;
    }

    // Validate Password
    if (_passwordController.text.isEmpty) {
      _errors["password"] = "Password is required";
      isValid = false;
    }
    if (_selectedGender == null) {
      _errors["gender"] = "gender is required";
      isValid = false;
    }

    // Confirm Password Match
    if (_confirmPasswordController.text != _passwordController.text) {
      _errors["confirm_password"] = "Passwords do not match";
      isValid = false;
    }

    // If invalid, refresh UI with errors
    if (!isValid) {
      setState(() {});
      return;
    }

    const String apiUrl = 'http://164.92.111.149/api/users/';
    String csrfToken = '${token}';

    try {
      final url = Uri.parse(apiUrl);
      final request = http.MultipartRequest('POST', url)
        ..headers['accept'] = 'application/json'
        ..headers['X-CSRFTOKEN'] = csrfToken
        ..fields['password'] = _passwordController.text
        ..fields['password_confirm'] = _confirmPasswordController.text
        ..fields['username'] = _usernameController.text
        ..fields['email'] = _emailController.text
        ..fields['full_name'] = _fullNameController.text
        ..fields['phone_number'] = _phoneController.text
        ..fields['birth_date'] = _birthDateController.text
        ..fields['gender'] = _selectedGender!
        ..fields['address'] = _addressController.text
        ..fields['user_type'] = 'patient'
        ..fields['is_verified'] = 'true'
        ..fields['is_active'] = 'true'
        ..fields['is_superuser'] = 'false'
        ..fields['is_staff'] = 'false'
        ..files.add(await http.MultipartFile.fromPath(
          'profile_image',
          file.path!,
        ));

      final response = await http.Response.fromStream(await request.send());

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print({
        "username": _usernameController.text,
        "email": _emailController.text,
        "full_name": _fullNameController.text,
        "phone_number": _phoneController.text,
        "birth_date": _birthDateController.text,
        "gender": _selectedGender,
        "address": _addressController.text,
        "user_type": _selectedUserType,
        "image": selectedFile,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registration Successfully',
              style: TextStyle(color: Colors.green),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
        /* Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: const Login(),
          ),
        ); */
      } else {
        // Handle API errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error (${response.statusCode}): ${response.body}',
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }
    } catch (e) {
      // Handle network or JSON parsing errors
      print('Error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An unexpected error occurred: $e',
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
  }

  Future<void> _selectBirthDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000), // Default year
      firstDate: DateTime(1900), // Start year for birthdate
      lastDate: DateTime.now(), // End at current year
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.teal, // Body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _birthDate = pickedDate;
        _birthDateController.text =
            DateFormat('yyyy-MM-dd').format(_birthDate!); // Format the date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginSignup()),
              );
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Image.asset(
                  "assets/images/Enayatak.png",
                  height: 80,
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 75,
                      backgroundColor: Colors.grey[300],
                      backgroundImage:
                          _profilePhoto != null && _profilePhoto!.isNotEmpty
                              ? FileImage(File(_profilePhoto!))
                              : null,
                      child: _profilePhoto == null || _profilePhoto!.isEmpty
                          ? const Icon(Icons.camera_alt,
                              size: 55, color: Colors.teal)
                          : null,
                    ),
                    FloatingActionButton(
                      onPressed: _pickFile,
                      mini: true,
                      backgroundColor: Colors.teal,
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                  ],
                ),
                selectedFile != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedFile = null;
                                _profilePhoto = ''; // Remove file
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.teal,
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Text(
                                'Remove file',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )
                    : GestureDetector(
                        onTap: _pickFile,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.teal,
                              borderRadius: BorderRadius.circular(10)),
                          child: const Text(
                            'Add file',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                const SizedBox(height: 30),
                CustomInputField(
                  controller: _fullNameController,
                  labelText: "Full Name",
                  hintText: "Enter your Name",
                  errorText: _errors["full_name"], // Pass error

                  keyboardType: TextInputType.name,
                  icon: Icons.person,
                  inputDecoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    labelStyle: TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                CustomInputField(
                  controller: _usernameController,
                  labelText: "Username",
                  hintText: "Enter your username",
                  keyboardType: TextInputType.name,
                  icon: Icons.person,
                  errorText: _errors["username"], // Pass error

                  inputDecoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    labelStyle: TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                CustomInputField(
                  controller: _emailController,
                  labelText: "Email",
                  hintText: "Enter your Email",
                  errorText: _errors["email"], // Pass error

                  keyboardType: TextInputType.emailAddress,
                  icon: Icons.email,
                  inputDecoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    labelStyle: TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                CustomInputField(
                  controller: _phoneController,
                  labelText: "Phone",
                  hintText: "Enter your Phone Number",
                  keyboardType: TextInputType.phone,
                  errorText: _errors["phone"], // Pass error

                  icon: Icons.phone,
                  inputDecoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    labelStyle: TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                CustomInputField(
                  controller: _passwordController,
                  labelText: "Password",
                  errorText: _errors["password"], // Pass error

                  hintText: "Enter your Password",
                  obscureText: true,
                  icon: Icons.lock,
                  inputDecoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    labelStyle: TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                CustomInputField(
                  controller: _confirmPasswordController,
                  labelText: "Confirm Password",
                  hintText: "Confirm your Password",
                  obscureText: true,
                  errorText: _errors["confirm_password"], // Pass error

                  icon: Icons.lock,
                  inputDecoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    labelStyle: TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                CustomInputField(
                  controller: _birthDateController,
                  labelText: "Birth Date",
                  hintText: "Select your Birth Date",
                  icon: Icons.calendar_today,
                  inputDecoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    labelStyle: TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onTap: () => _selectBirthDate(),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    labelStyle: TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon:
                        const Icon(Icons.transgender, color: Colors.teal),
                  ),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedUserType,
                  items: const [
                    DropdownMenuItem(value: 'patient', child: Text('patient')),
                    DropdownMenuItem(value: 'nurse', child: Text('nurse')),
                    DropdownMenuItem(value: 'lab', child: Text('lab')),
                    DropdownMenuItem(value: 'admin', child: Text('admin')),
                    DropdownMenuItem(
                        value: 'hospital', child: Text('hospital')),
                    DropdownMenuItem(value: 'doctor', child: Text('doctor')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedUserType = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'UserType',
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    labelStyle: TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                    /*  prefixIcon:
                        const Icon(Icons.type, color: Colors.teal), */
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => _submitDetails(selectedFile!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 60),
                  ),
                  child: const Text(
                    "Register",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
