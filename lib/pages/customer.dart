import 'dart:convert'; // For JSON encoding
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Customer extends StatefulWidget {
  const Customer({super.key});

  @override
  State<Customer> createState() => _CustomerState();
}

class _CustomerState extends State<Customer> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the form fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController localityController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();

  // Variable to hold the selected address type (Home or Work)
  String addressType = 'Home'; // Default value

  // Method to send PUT request
  Future<void> submitCustomerDetails() async {
    final String apiUrl = 'https://bookstore.incubation.bridgelabz.com/bookstore_user/edit_user';
    
    // Collect data from form fields
    final Map<String, dynamic> customerData = {
      'name': nameController.text,
      'phone': phoneController.text,
      'pincode': pincodeController.text,
      'locality': localityController.text,
      'address': addressController.text,
      'city': cityController.text,
      'landmark': landmarkController.text,
      'addressType': addressType, // Add the selected address type to the data
    };

    try {
      final response = await http.put(
        Uri.parse(apiUrl),  // Use PUT method
        body: json.encode(customerData),  // Send customer data
        headers: {'Content-Type': 'application/json'},  // Set content type to JSON
      );

      if (response.statusCode == 200) {
        // Handle successful response
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Customer details updated successfully')));
      } else {
        // Handle failure response
        final errorMessage = json.decode(response.body)['message'] ?? 'Failed to update customer details';
        print('Error: $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update customer details')));
      }
    } catch (e) {
      // Handle error
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Details'),
        backgroundColor: Colors.blue,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Name Field
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(hintText: "Enter name"),
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                
                // Phone Number Field
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(hintText: "Enter phone number"),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),

                // Pincode Field
                TextFormField(
                  controller: pincodeController,
                  decoration: InputDecoration(hintText: "Enter pincode"),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your pincode';
                    }
                    return null;
                  },
                ),

                // Locality Field
                TextFormField(
                  controller: localityController,
                  decoration: InputDecoration(hintText: "Enter locality"),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your locality';
                    }
                    return null;
                  },
                ),

                // Address Field
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(hintText: "Enter address"),
                  keyboardType: TextInputType.streetAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),

                // City/Town Field
                TextFormField(
                  controller: cityController,
                  decoration: InputDecoration(hintText: "Enter city/town"),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your city/town';
                    }
                    return null;
                  },
                ),

                // Landmark Field
                TextFormField(
                  controller: landmarkController,
                  decoration: InputDecoration(hintText: "Enter landmark"),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    return null;
                  },
                ),
                
                // Address Type Selector: Home or Work
                SizedBox(height: 20),
                Text('Select Address Type'),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Home'),
                        value: 'Home',
                        groupValue: addressType,
                        onChanged: (String? value) {
                          setState(() {
                            addressType = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Work'),
                        value: 'Work',
                        groupValue: addressType,
                        onChanged: (String? value) {
                          setState(() {
                            addressType = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                // Submit Button
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      submitCustomerDetails();  // Submit the form data
                    }
                  },
                  child: Text('ADD'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
