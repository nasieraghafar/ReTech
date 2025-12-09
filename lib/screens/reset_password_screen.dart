import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mbap_project/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this line

class ResetPasswordScreen extends StatelessWidget {
  // Retrieve the FirebaseService instance from GetIt
  FirebaseService fbService = GetIt.instance<FirebaseService>();
  static String routeName = '/reset-password'; // Define the route name for navigation
  String? email; // Variable to hold the email address entered by the user
  var form = GlobalKey<FormState>(); // Global key for form state management

  // Method to handle password reset
  void reset(BuildContext context) {
    // Validate form
    if (form.currentState!.validate()) {
      form.currentState!.save(); // Save form data if validation passes
      // Call the forgotPassword method from FirebaseService
      fbService.forgotPassword(email!).then((value) {
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide any current SnackBar
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please check your email to reset your password!'), // Notify user of reset request
        ));
        Navigator.of(context).pop(); // Go back to the previous screen
      }).catchError((error) {
        FocusScope.of(context).unfocus(); // Dismiss the keyboard
        String message = error.toString();
        if (error is FirebaseAuthException) {
          message = error.message ?? "An error occurred"; // Use the error message from FirebaseAuthException if available
        }
        ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Hide any current SnackBar
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message), // Display the error message
        ));
      });
    } else {
      // If form is not valid, show a SnackBar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please correct the errors in the form.'), // Prompt user to fix form errors
      ));
    }
  }

  // Validator for email field
  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Please provide an email address."; // Error message if email field is empty
    }
    // Use a regular expression to validate email
    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return "Please provide a valid email address."; // Error message if email format is invalid
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white, // Set the text color in the AppBar
        title: Text(
          'Reset Password',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make the title text bold
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(10), // Add padding around the form
        child: Form(
          key: form, // Associate the form key with the Form widget
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch column children to the maximum width
            children: [
              SizedBox(height: 20), // Add space above the email field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Email', // Label text for the email field
                  border: OutlineInputBorder(), // Border style for the email field
                  filled: true,
                  fillColor: Colors.grey[200], // Background color for the email field
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 15), // Padding inside the email field
                ),
                keyboardType: TextInputType.emailAddress, // Set the keyboard type for email input
                validator: emailValidator, // Validate the email input
                onSaved: (value) {
                  email = value; // Save the email value
                },
              ),
              const SizedBox(height: 20), // Add space above the reset button
              ElevatedButton(
                onPressed: () {
                  reset(context); // Call the reset method on button press
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, // Set the text color in the button
                ),
                child: const Text(
                  'Reset Password',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Make the button text bold
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
