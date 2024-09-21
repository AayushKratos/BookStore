import 'dart:convert';  // For encoding JSON
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controllers for the form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();  // Key to validate the form
  bool isLoading = false;  // Loading state for the register button

  // Method to send the registration request to the API
  Future<void> registerUser() async {
    // API endpoint
    const String apiUrl = 'https://bookstore.incubation.bridgelabz.com/bookstore_user/registration';
    
    setState(() {
      isLoading = true;  // Show loading while sending the request
    });

    try {
      // Create the request payload
      final Map<String, dynamic> registrationData = {
        "fullName": nameController.text,
        "email": emailController.text,
        "password": passwordController.text,
        "phone": phoneController.text,
      };

      // Make the POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(registrationData),
      );

      setState(() {
        isLoading = false;
      });

      // Check the response
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Handle success
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration successful!')));
        print(responseData);  // You can process the response data here if needed
      } else {
        final errorResponse = json.decode(response.body);
        // Handle error response
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${errorResponse['message']}')));
        print('Error: ${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle the exception
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,  // Link the form key to the form widget
          child: Column(
            children: [
              // Full Name field
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              
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
                obscureText: true,  // Hide the text for password input
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              
              // Phone field
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  } else if (value.length != 10) {
                    return 'Phone number must be 10 digits';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),

              // Register button
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        // Check if the form is valid before sending the request
                        if (_formKey.currentState!.validate()) {
                          registerUser();  // Call the registration function
                        }
                      },
                      child: Text('Register'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
