import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mbap_project/modals/repair_request1.dart';
import 'package:mbap_project/screens/own_repair_details_screen.dart';
import 'package:mbap_project/services/firebase_service.dart';
import 'package:mbap_project/widgets/nav_bar.dart';
import 'package:get_it/get_it.dart';

class EditScreen extends StatefulWidget {
  // Get the instance of FirebaseService using GetIt for dependency injection
  final FirebaseService fbService = GetIt.instance<
      FirebaseService>(); // Get the instance of firebase service using getit for dependency injection
  // Define the route name for navigating to this screen
  static String routeName = '/edit';

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  // Get an instance of FirebaseService using GetIt for dependency injection
  final FirebaseService fbService = GetIt.instance<FirebaseService>();

  // Global key to identify the form and manage its state
  var form = GlobalKey<FormState>();
  // Variables to store form data
  String? title;
  String? detail;
  String? deviceType;
  DateTime? createDate;
  File? receiptPhoto;

  // Method to pick an image from camera or gallery
  Future<void> pickImage(int mode) async {
    // Determine the source of the image based on the mode (0 for camera, 1 for gallery)
    ImageSource chosenSource =
        mode == 0 ? ImageSource.camera : ImageSource.gallery;
    final imageFile = await ImagePicker().pickImage(
        source: chosenSource, maxWidth: 600, imageQuality: 50, maxHeight: 150);
    // If an image is picked, update the state with the image file
    if (imageFile != null) {
      setState(() {
        receiptPhoto = File(imageFile.path);
      });
    }
  }

  // Method to save the form data and update the repair request
  void saveForm(String id) async {
    // Validate the form input
    bool isValid = form.currentState!.validate();
    if (isValid) {
      form.currentState!.save();
      debugPrint('Form is valid');

      // Show a loading indicator while updating the request
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
                Text('Updating...'),
              ],
            ),
          );
        },
      );

      try {
        // If a new receipt photo is provided, upload it and get the URL
        // Otherwise, get the existing image URL
        String? imageUrl;
        if (receiptPhoto != null) {
          imageUrl = await fbService.addReceiptPhoto(receiptPhoto!);
        } else {
          imageUrl = await fbService.getImageUrlById(id);
        }

        createDate = DateTime.now(); // Update create date to current time

        // Update the repair request in Firestore
        await fbService.updateRequest(
            imageUrl!,
            id,
            title!,
            deviceType!,
            detail!,
            createDate!);

        FocusScope.of(context).unfocus(); // Hide the keyboard
        form.currentState!.reset(); // Reset the form state
        createDate = null;
        receiptPhoto = null;

        // Dismiss the loading indicator
        Navigator.of(context).pop();

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Repair request edited successfully!'),
          duration: Duration(seconds: 1),
        ));

        // Navigate to the own details screen
        Navigator.of(context).pushReplacementNamed(
          OwnDetailsScreen.routeName,
          arguments: id,
        );
      } catch (error) {
        // Dismiss the loading indicator
        Navigator.of(context).pop();
        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ' + error.toString()),
        ));
      }
    } else {
      debugPrint('Form is not valid');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the selected repair request passed as an argument
    Requests
        selectedRequest = // Get the selected repair request passed as an argument
        ModalRoute.of(context)?.settings.arguments as Requests;
    // Initialize createDate if it's null
    if (createDate == null) createDate = selectedRequest.createDate;

    return Scaffold(
      // AppBar with title and white icon theme
      appBar: AppBar(
        title: Text('Edit',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Form(
            key: form, // Use the form key for validation
            child: Column(
              children: [
                const SizedBox(height: 30),
                // Title text for the form
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Edit Repair',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Request',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
                ),
                SizedBox(height: 30),
                // Input field for title with initial value from selected request
                TextFormField(
                  initialValue: selectedRequest.title,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  ),
                  onSaved: (value) {
                    title = value as String;
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
                // Dropdown for selecting device type with initial value from selected request
                DropdownButtonFormField(
                  value: selectedRequest.deviceType,
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
                  onSaved: (value) {
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
                // Input field for details with initial value from selected request
                TextFormField(
                  initialValue: selectedRequest.detail,
                  decoration: InputDecoration(
                    labelText: 'Details',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  ),
                  onSaved: (value) {
                    detail = value as String?;
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
                      child: receiptPhoto != null
                          ? FittedBox(
                              fit: BoxFit.fill,
                              child: Image.file(receiptPhoto!),
                            )
                          : selectedRequest.imageUrl != ''
                              ? FittedBox(
                                  fit: BoxFit.fill,
                                  child:
                                      Image.network(selectedRequest.imageUrl),
                                )
                              : Center(),
                    ),
                    Column(
                      children: [
                        // Button to take a photo
                        TextButton.icon(
                          icon:
                              const Icon(Icons.camera_alt, color: Colors.black),
                          onPressed: () {
                            pickImage(0);
                          },
                          label: const Text('Take Photo',
                              style: TextStyle(color: Colors.black)),
                        ),
                        // Button to pick an image from gallery
                        TextButton.icon(
                          icon: const Icon(Icons.image, color: Colors.black),
                          onPressed: () {
                            pickImage(1);
                          },
                          label: const Text('Add Image',
                              style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(height: 50),
                // Button to submit the form and save the changes
                ElevatedButton(
                  onPressed: () {
                    saveForm(selectedRequest.id);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(200, 50),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                  ),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 2),
    );
  }
}
