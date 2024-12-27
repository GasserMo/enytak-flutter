import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Colors/colors.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;

class MedicalReportsPage extends StatefulWidget {
  const MedicalReportsPage({super.key});

  @override
  _MedicalReportsPageState createState() => _MedicalReportsPageState();
}

class _MedicalReportsPageState extends State<MedicalReportsPage> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? medicalHistory;
  String? currentMedications;
  String? allergies;
  String? testResults;
  String? medicalNotes;
  bool _isRecordAvailable = false;
  bool _isUploadingFile = false; // Track file upload state
  String? file_Type;
  int? medicalRecordId; // Store the medical record ID
  PlatformFile? selectedFile; // Store the selected file
  // Controller for text fields
  final TextEditingController _medicalHistoryController =
      TextEditingController();
  final TextEditingController _currentMedicationsController =
      TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _testResultsController = TextEditingController();
  final TextEditingController _medicalNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMedicalFile();
    _fetchMedicalRecord();
  }

  // Fetch the medical record from API
  Future<void> _fetchMedicalRecord() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse('http://164.92.111.149/api/medical-records/');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['results'] != null && data['results'].isNotEmpty) {
        // Try to find a record for the user
        final record = data['results'].firstWhere(
          (record) => record['user'] == userId,
          orElse: () => null,
        );
        print('1 ${_isRecordAvailable}');

        if (record != null) {
          setState(() {
            _isLoading = false;
            _isRecordAvailable = true; // Record found, so show the data
            medicalHistory = record['medical_history'];
            currentMedications = record['current_medications'];
            allergies = record['allergies'];
            testResults = record['test_results'];
            medicalNotes = record['medical_notes'];
            medicalRecordId = record['id']; // Save the medical record ID
          });
        } else {
          setState(() {
            _isLoading = false;
            _isRecordAvailable =
                false; // No records for this user, show text fields
          });
        }
        print('2 ${_isRecordAvailable}');
      } else {
        print('3 ${_isRecordAvailable}');
        _isRecordAvailable = false; // No records at all, show text fields

        setState(() {
          _isLoading = false;
          _isRecordAvailable = false; // No records at all, show text fields
        });
      }
      print('4 ${_isRecordAvailable}');
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<dynamic> results = [];
  Future<void> _fetchMedicalFile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse('http://164.92.111.149/api/medical-files/');

    final response = await http.get(
      url,
      headers: {
        'accept': 'application/json; charset=utf-8',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      results = data['results'];

      if (results != null) {
        results = data['results']
            .where((result) => result['medical_record'] == medicalRecordId)
            .toList();

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _isRecordAvailable = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to upload a medical file
  Future<void> _uploadMedicalFile(PlatformFile file) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null ||
        file.path == null ||
        file_Type == null ||
        medicalRecordId == null) {
      return;
    }

    setState(() {
      _isUploadingFile = true; // Start uploading indicator
    });

    final url = Uri.parse('http://164.92.111.149/api/medical-files/');

    final request = http.MultipartRequest('POST', url)
      ..fields['file_type'] = file_Type!
      ..fields['medical_record'] = medicalRecordId.toString()
      ..files.add(await http.MultipartFile.fromPath('file', file.path!));

    final response = await http.Response.fromStream(await request.send());

    setState(() {
      _isUploadingFile = false; // Stop uploading indicator
    });

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);

      String uploadedFilePath = responseData['file'];

      _showSnackbar('File uploaded successfully');
      await _fetchMedicalFile();

      print('Uploaded file path: $uploadedFilePath');
    } else {
      _showSnackbar('Failed to upload file. Please try again.');
      print('Upload error: ${response.body}');
    }
  }

  // Pick a file from the user's device
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        selectedFile = file; // Store the selected file
      });
    }
  }

  // Add dropdown for file type selection
  Widget _buildFileTypeDropdown() {
    return DropdownButton<String>(
      value: file_Type,
      hint: Text("Select file type"),
      onChanged: (String? newValue) {
        setState(() {
          file_Type = newValue;
        });
      },
      items: <String>['analysis', 'xray', 'prescription', 'other']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  // Post a new medical record to the API
  Future<void> _addNewMedicalRecord() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      return;
    }

    if (_medicalHistoryController.text.isEmpty ||
        _currentMedicationsController.text.isEmpty ||
        _allergiesController.text.isEmpty ||
        _testResultsController.text.isEmpty ||
        _medicalNotesController.text.isEmpty) {
      _showSnackbar('Please fill in all fields');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final url = Uri.parse('http://164.92.111.149/api/medical-records/');

    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'medical_history': _medicalHistoryController.text,
      'current_medications': _currentMedicationsController.text,
      'allergies': _allergiesController.text,
      'test_results': _testResultsController.text,
      'medical_notes': _medicalNotesController.text,
      'user': userId,
    });

    final response = await http.post(url, headers: headers, body: body);

    setState(() {
      _isSaving = false;
    });

    if (response.statusCode == 201) {
      _fetchMedicalRecord();
    } else {
      _showSnackbar('Failed to create record. Please try again');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Reports'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isRecordAvailable
              ? SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoText('Medical History', medicalHistory),
                        _buildInfoText(
                            'Current Medications', currentMedications),
                        _buildInfoText('Allergies', allergies),
                        _buildInfoText('Test Results', testResults),
                        _buildInfoText('Medical Notes', medicalNotes),
                        const SizedBox(height: 16),
                        const Text(
                          'Upload Medical File:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_isRecordAvailable}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        _buildFileTypeDropdown(),
                        const SizedBox(height: 8),
                        selectedFile != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Selected file: ${selectedFile!.name}'),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedFile = null; // Remove file
                                      });
                                    },
                                    child: const Text('Remove file'),
                                  ),
                                ],
                              )
                            : ElevatedButton(
                                onPressed: () {
                                  _pickFile();
                                },
                                child: const Text('Choose file'),
                              ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: file_Type != null && selectedFile != null
                              ? () {
                                  _uploadMedicalFile(selectedFile!);
                                }
                              : null,
                          child: _isUploadingFile
                              ? const CircularProgressIndicator()
                              : const Text('Add Medical File'),
                        ),
                        const SizedBox(height: 16),
                        if (results.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: results.length,
                            itemBuilder: (context, index) {
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title:
                                      Text(results[index]['file_type'] ?? ''),
                                  subtitle: Text(results[index]['file'] ?? ''),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(
                            'Medical History', _medicalHistoryController),
                        _buildTextField('Current Medications',
                            _currentMedicationsController),
                        _buildTextField('Allergies', _allergiesController),
                        _buildTextField('Test Results', _testResultsController),
                        _buildTextField(
                            'Medical Notes', _medicalNotesController),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _addNewMedicalRecord,
                          child: _isSaving
                              ? const CircularProgressIndicator()
                              : const Text('Add New Medical Record'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

// Helper function to build text fields for adding medical record
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildInfoText(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        '$title: ${value ?? 'Not available'}',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}