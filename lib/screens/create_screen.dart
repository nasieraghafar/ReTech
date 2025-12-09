import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mbap_project/services/firebase_service.dart';
import 'package:mbap_project/widgets/create_dialog.dart';
import 'package:mbap_project/widgets/nav_bar.dart';

class CreateScreen extends StatefulWidget {
  // Define the route name for navigating to this screen
  static String routeName = '/create';

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  // Get an instance of FirebaseService using GetIt for dependency injection
  final FirebaseService fbService = GetIt.instance<
      FirebaseService>();
  // Global key to identify the form and validate it
  final form =
      GlobalKey<FormState>(); // Global key to identify the form and validate it
  // Varaibles to store form input values
  String? title;
  String? deviceType;
  String? detail;
  File? receiptPhoto;
  DateTime? createDate;

  // Function to pick an image from either the camera or gallery
  Future<Null> pickImage(mode) {
    // Determine the source based on the mode (0 for camera, 1 for gallery)
    ImageSource chosenSource =
        mode == 0 ? ImageSource.camera : ImageSource.gallery;
    return ImagePicker()
        .pickImage(
            source: chosenSource,
            maxWidth: 600,
            imageQuality: 50,
            maxHeight: 150)
        .then((imageFile) {
      // If an image is picked, update the state with the image file
      if (imageFile != null) {
        setState(() {
          receiptPhoto = File(imageFile.path);
        });
      }
    });
  }

  // Function to save the form data and handle Firebase operations
  void saveForm() {
    // Validate the form input
    bool isValid = form.currentState!.validate();
    // Check if the form is valid and an image is provided
    if (isValid && receiptPhoto != null) {
      // Save form state
      form.currentState!.save();
      // Set createDate to the current date if not provided
      if (createDate == null) {
        createDate = DateTime.now();
        createDate =
            DateTime(createDate!.year, createDate!.month, createDate!.day);
      }

      // Show a loading indicator while creating the request
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text('Creating...'),
              ],
            ),
          );
        },
      );
      
      // Upload the receipt photo to Firebase and create the repair request
      fbService.addReceiptPhoto(receiptPhoto!).then((imageUrl) {
        // Upload the receipt photo to firebase and create the repair request
        fbService
            .addRequest(title!, deviceType!, detail!, imageUrl!, createDate!)
            .then((value) {
          // Hide the keyboard
          FocusScope.of(context).unfocus();
          // Resets the form
          form.currentState!.reset();
          createDate = null;
          receiptPhoto = null;
          Navigator.of(context).pop(); // Dismiss the loading indicator
          // Show a success dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CreateDialog();
            },
          );
        }).onError((error, stackTrace) {
          // Dismiss the loading indicator
          Navigator.of(context).pop();
          // Shows error message in AlertDialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Error: ' + error.toString()),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        });
      });
    } else {
      // Show a snack bar if the image is not provided
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please provide an image.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with title and no back button
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Create',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Form(
            key: form, // Use the form key for validation
            child: Column(children: [
              const SizedBox(height: 30),
              // Title text for the form
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Create a Repair',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Request',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
              ),
              SizedBox(height: 30),
              // Input field for title
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                ),
                onSaved: (value) {
                  title = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please provide a title.';
                  else if (value.length < 5)
                    return 'Please enter a title that is at least 5 characters.';
                  else
                    return null;
                },
              ),
              SizedBox(height: 7),
              // Dropdown for selecting device type
              DropdownButtonFormField(
                // Device type dropdown
                decoration: const InputDecoration(
                  label: Text('Device Type'),
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                ),
                items: const [
                  DropdownMenuItem(value: 'Phone', child: Text('Phone')),
                  DropdownMenuItem(value: 'Laptop', child: Text('Laptop')),
                  DropdownMenuItem(value: 'TV', child: Text('TV')),
                  DropdownMenuItem(value: 'Desktop', child: Text('Desktop')),
                ],
                onChanged: (value) {
                  deviceType = value;
                },
                validator: (value) {
                  if (value == null)
                    return "Please provide a device type.";
                  else
                    return null;
                },
              ),
              SizedBox(height: 7),
              // Input field for details
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Details',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                ),
                onSaved: (value) {
                  detail = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please provide details.';
                  else if (value.length < 5)
                    return 'Please enter details that is at least 5 characters.';
                  else
                    return null;
                },
              ),
              const SizedBox(height: 20),
              // Section for picking and displaying an image
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: 150,
                      height: 100,
                      decoration: const BoxDecoration(color: Colors.grey),
                      child: receiptPhoto != null
                          ? FittedBox(
                              fit: BoxFit.fill,
                              child: Image.file(receiptPhoto!))
                          : Center()), // Display image if available
                  Column(
                    children: [
                      // Button to take a photo
                      TextButton.icon(
                        icon: const Icon(Icons.camera_alt, color: Colors.black),
                        onPressed: () => pickImage(0),
                        label: const Text('Take Photo',
                            style: TextStyle(color: Colors.black)),
                      ),
                      // Button to pick an image from gallery
                      TextButton.icon(
                        icon: const Icon(Icons.image, color: Colors.black),
                        onPressed: () => pickImage(1),
                        label: const Text('Add Image',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(height: 50),
              // Button to submit the form
              ElevatedButton(
                // Create button
                onPressed: () {
                  saveForm();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 50),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                ),
                child: Text(
                  'Create',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ]),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
    );
  }
}
