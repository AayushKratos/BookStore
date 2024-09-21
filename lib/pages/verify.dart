import 'dart:convert';  // For encoding and decoding JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VerificationPage extends StatefulWidget {
  final String email; // Email to be used for verification

  const VerificationPage({required this.email, super.key});

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final TextEditingController otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();  // Key for the form
  bool isLoading = false;  // Loading state for the button

  // Function to retrieve token from SharedPreferences
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');  // Get the stored auth token
  }

  // Function to send OTP for verification
  Future<void> verifyUser() async {
    const String apiUrl = 'https://bookstore.incubation.bridgelabz.com/bookstore_user/verification';

    setState(() {
      isLoading = true;  // Show loading indicator
    });

    try {
      final String? token = await getToken();  // Get the auth token from SharedPreferences

      if (token == null) {
        throw 'Token not found. Please log in again.';
      }

      final Map<String, dynamic> verificationData = {
        'email': widget.email,  // Pass the email
        'otp': otpController.text,  // Pass the entered OTP
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-access-token': 'Bearer $token',  // Pass the token in the header
        },
        body: jsonEncode(verificationData),
      );

      setState(() {
        isLoading = false;  // Hide loading indicator
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification Successful!')),
        );
        print('Verification Success: ${responseData['message']}');
        // Proceed to next screen if needed
      } else {
        final errorResponse = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification Failed: ${errorResponse['message']}')),
        );
        print('Verification Failed: ${errorResponse['message']}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;  // Hide loading indicator
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Account'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,  // Link the form key to the form widget
          child: Column(
            children: [
              // OTP field
              TextFormField(
                controller: otpController,
                decoration: InputDecoration(labelText: 'Enter OTP'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the OTP';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 20),

              // Verify button
              isLoading
                  ? CircularProgressIndicator()  // Show loading indicator if request is in progress
                  : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          verifyUser();  // Call the verification function
                        }
                      },
                      child: Text('Verify'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
