import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbap_project/screens/home_screen.dart';

class NamePhoneNumberPrompt extends StatefulWidget {
  // Define the route name for navigating to this screen
  static String routeName = '/name_phone_prompt';

  @override
  _NamePhoneNumberPromptState createState() => _NamePhoneNumberPromptState();
}

class _NamePhoneNumberPromptState extends State<NamePhoneNumberPrompt> {
  // Controllers to manage the input text fields
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  // ValueNotifier to handle loading state
  final _isLoading = ValueNotifier<bool>(false);

  // Method to handle form submission
  void _submit() async {
    // Retrieve and trim the values from the text controllers
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    // Validate input
    if (name.isEmpty || phone.isEmpty) {
      // Show an error message if either field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both name and phone number.')),
      );
      return;
    }
    // Set loading state to true
    _isLoading.value = true;

    try {
      // Get the currently logged-in user
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Save the user data to Firestore under the 'users' collection
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email, // Store the user's email
          'name': name, // Store the user's name
          'phoneNumber': phone, // Store the user's phone number
        });
        // Navigate to HomeScreen and remove all previous routes
        Navigator.of(context).pushNamedAndRemoveUntil(
          HomeScreen.routeName,
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      // Show an error message if saving data fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save user data: $e')),
      );
    } finally {
      // Set loading state to false after the operation
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Enter your details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Text field for user name input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            // Text field for user phone number input
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            SizedBox(height: 20),
            ValueListenableBuilder<bool>(
              // Listen to changes in the loading state
              valueListenable: _isLoading,
              builder: (context, isLoading, child) {
                return isLoading
                    ? CircularProgressIndicator() // Show loading indicator when loading
                    : ElevatedButton(
                        onPressed: _submit, // Call _submit method when button is pressed
                        child: Text('Submit'),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}