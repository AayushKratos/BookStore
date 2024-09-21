import 'dart:convert';  // For encoding and decoding JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();  // Key for the form
  bool isLoading = false;  // Loading state for the button

  // Function to save the token using SharedPreferences
  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Function to send login credentials to the API
  Future<void> loginUser() async {
    const String apiUrl = 'https://bookstore.incubation.bridgelabz.com/bookstore_user/login';

    setState(() {
      isLoading = true;  // Show loading indicator
    });

    try {
      final Map<String, dynamic> loginData = {
        'email': emailController.text,
        'password': passwordController.text,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginData),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final String token = responseData['result']['accessToken'];

        // Save the token
        await saveToken(token);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Successful!')),
        );
        print('Token: $token');
        // Navigate to the next screen if needed
      } else {
        final errorResponse = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${errorResponse['message']}')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,  // Link the form key to the form widget
          child: Column(
            children: [
              // Email field
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              
              // Password field
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,  // Hide the password input
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 20),

              // Login button
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          loginUser();  // Call the login function
                        }
                      },
                      child: Text('Login'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
