import 'package:flutter/material.dart';
import 'package:mbap_project/widgets/register_dialog.dart';
import 'package:mbap_project/services/firebase_service.dart';

class RegisterScreen extends StatefulWidget {
  // Define the route name for navigating to this screen
  static String routeName = '/register';

  @override
  _RegisterScreenState createState() => _RegisterScreenState(); // Create state for RegisterScreen
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>(); // Key to identify the form
  final FirebaseService _firebaseService = FirebaseService(); // Instance of FirebaseService for registration

  // Controllers to get the text input values
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false; // Add a state variable for loading

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register', // Title of the AppBar
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true, // Center the title
        iconTheme: IconThemeData(color: Colors.white), // Color of icons in AppBar
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(10), // Padding around the form
              child: Form(
                key: _formKey, // Assign the form key
                child: Column(
                  children: [
                    const SizedBox(height: 30), // Spacing
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Enter',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'the following',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                      ),
                    ),
                    SizedBox(height: 30), // Spacing between title and form fields
                    // Email input field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(), // Border for the input field
                        filled: true,
                        fillColor: Colors.grey[200], // Background color of the input field
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email'; // Validation message if email is empty
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 7), // Spacing between form fields
                    // Password input field
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      ),
                      obscureText: true, // Hide text for password input
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password'; // Validation message if password is empty
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters'; // Validation message for short password
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 7),
                    // Confirm Password input field
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      ),
                      obscureText: true, // Hide text for password input
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password'; // Validation message if confirm password is empty
                        } else if (value != _passwordController.text) {
                          return 'Passwords do not match'; // Validation message if passwords do not match
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 7),
                    // Name input field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name'; // Validation message if name is empty
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 7),
                    // Phone Number input field
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      ),
                      keyboardType: TextInputType.phone, // Keyboard type for phone number
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number'; // Validation message if phone number is empty
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 50), // Spacing before the button
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // If form is valid, proceed with registration
                          setState(() {
                            _isLoading = true; // Show loading indicator
                          });
                          try {
                            // Call the Firebase service to register the user
                            await _firebaseService.register(
                              _emailController.text,
                              _passwordController.text,
                              _nameController.text,
                              _phoneController.text,
                            );
                            Navigator.of(context).pop(); // Navigate back after successful registration
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return RegisterDialog(); // Show success dialog
                              },
                            );
                          } catch (e) {
                            // Handle registration error
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Registration Error'), // Dialog title
                                  content: Text(e.toString()), // Display error message
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close dialog
                                      },
                                      child: Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } finally {
                            setState(() {
                              _isLoading = false; // Hide loading indicator
                            });
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(200, 50), // Button size
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                        ),
                      ),
                      child: Text(
                        'Register',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54, // Overlay color
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
