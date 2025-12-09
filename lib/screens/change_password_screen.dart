import 'package:flutter/material.dart';
import 'package:mbap_project/services/firebase_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  // Define the route name for navigating to this screen
  static String routeName = '/change-password';

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // Controllers for the text fields to manage their state and retrieve values
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  // Key to manage the form state and validate form input
  final _formKey = GlobalKey<FormState>();
  // Instance of FirebaseService to handle Firebase authentication and operations
  final FirebaseService _firebaseService = FirebaseService();
  // Variable to manage whether the app is currently loading or not
  bool _isLoading = false;

  @override
  void dispose() {
    // Dispose of the text controllers when the widget is removed from the widget tree
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // Method to handle password change logic
  Future<void> _changePassword() async { 
    // Check if the form is valid
    if (_formKey.currentState!.validate()) {
      // Retrieve the text from the controllers
      final currentPassword = _currentPasswordController.text;
      final newPassword = _newPasswordController.text;
      // Show loading indicator by setting _isLoading to true
      setState(() {
        _isLoading = true;
      });

      try {
        // Call the reauthentication method from FirebaseService with the current password
        await _firebaseService.reauthenticate(currentPassword);

        // Call the method to change the password from FirebaseService with the new password
        await _firebaseService.changePassword(newPassword);

        // Show a success message using a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password changed successfully.')),
        );

        // Optionally navigate back to the previous screen
        Navigator.of(context).pop();
      } catch (e) {
        // Show an error message if the reauthentication or password change fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wrong current password')),
        );
      } finally {
        // Hide the loading indicator by setting _isLoading to false
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with a title for the Change Password screen
      appBar: AppBar(
        title: Text(
          'Change Password',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Use the form key for validation
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text field for entering the current password
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true, // Hide the text input
                decoration: InputDecoration(
                  labelText: 'Current Password',
                ),
                validator: (value) {
                  // Validation logic for the current password field
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              // Text field for entering the new password
              TextFormField(
                controller: _newPasswordController,
                obscureText: true, // Hide the text input
                decoration: InputDecoration(
                  labelText: 'New Password',
                ),
                validator: (value) {
                  // Validation logic for the new password field
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Show a loading indicator or a button based on _isLoading
              _isLoading
                  ? Center(child: CircularProgressIndicator()) // Display loading spinner
                  : ElevatedButton(
                      onPressed: _changePassword, // Call the _changePassword method when pressed
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                      ),
                      child: Text('Change Password'), // Button text
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
