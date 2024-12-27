import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PasswordResetPage extends StatefulWidget {
  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _requestPasswordReset() async {
    final String apiUrl = 'http://164.92.111.149/api/password/reset/';

    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your email.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': 'gasser@gmail.com',
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset request sent successfully.'),
          ),
        );
      } else {
        final responseData = json.decode(response.body);
        print(responseData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error: ${responseData['detail'] ?? 'Unable to process request.'}'),
          ),
        );
      }
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Password Reset'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter your email address to request a password reset link.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _requestPasswordReset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Request Reset',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
