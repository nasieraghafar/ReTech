import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mbap_project/modals/repair_request1.dart'; // Import your Requests model
import 'package:mbap_project/services/firebase_service.dart';
import 'package:mbap_project/services/notifi_service.dart';
import 'package:mbap_project/widgets/nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatefulWidget {
  // Define the route name for navigation
  static String routeName = '/details';

  @override
  State<DetailScreen> createState() => _DetailScreenState(); // Create state for DetailScreen
}

class _DetailScreenState extends State<DetailScreen> {
    final NotificationService notificationService = GetIt.instance<NotificationService>(); // Get instance of NotificationService
  // Method to select a date and time for scheduling a notification
  Future<void> _selectNotificationDateTime() async {
    // Show date picker to select a date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      // Show time picker to select a time
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final DateTime scheduledDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
 
        // Schedule the notification
        notificationService.scheduleNotification(
          id: 0, // Notification ID (should be unique)
          title: 'Scheduled Repair Meeting', // Notification title
          body: 'You have a scheduled meeting with another user to repair a device!', // Notification body
          scheduledNotificationDateTime: scheduledDateTime, // Date and time when the notification should be triggered
        );
        // Show a snackbar to confirm that the notification has been scheduled
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification scheduled!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract the request ID passed from the previous screen
    final String id = ModalRoute.of(context)!.settings.arguments
        as String; // Extracting the id passed from the previous screen
    final FirebaseService fbService = GetIt.instance<
        FirebaseService>(); // Get the instance of firebase service using getit for dependency injection

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Details', // Title of the AppBar
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications), // Notification icon button
            onPressed: _selectNotificationDateTime // Schedule a notification on press
          ),
        ],
      ),
      body: FutureBuilder<Requests>(
        future: fbService
            .getRequestById(id), // Fetch request details using the ID
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loading indicator while waiting for data
            return Center(
                child:
                    CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // Display an error message if there is an error
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            // Display a message if no data is found
            return Center(child: Text('Request not found.'));
          }

          final Requests item = snapshot
              .data!; // Extracting the request object from the snapshot data

          // Fetch user data based on the email associated with the request
          return FutureBuilder<Map<String, dynamic>?>(
            future: fbService.getUserDataByEmail(item.email),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                // Display a loading indicator while waiting for user data
                return Center(child: CircularProgressIndicator());
              }
              if (userSnapshot.hasError) {
                // Display an error message if there is an error fetching user data
                return Center(child: Text('Error: ${userSnapshot.error}'));
              }
              if (!userSnapshot.hasData || userSnapshot.data == null) {
                // Display a message if user data is not found
                return Center(child: Text('User data not found.'));
              }

              // Extract phone number from user data
              String phoneNumber = userSnapshot.data!['phoneNumber'];

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display the image related to the request
                    Image.network(
                      item.imageUrl,
                      width: double.infinity, // Make the image as wide as the screen
                      fit: BoxFit.cover, // Cover the area without distorting the image
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0), // Padding around the content
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            // Displaying the title of the request
                            item.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            // Displaying the details of the request
                            'Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(item.detail),
                          SizedBox(height: 10),
                          Text(
                            // Displaying the device type associated with the request
                            'Device: ${item.deviceType}',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            // Displaying the creation date of the request
                            'Date: ${item.createDate.toLocal().toString().split(' ')[0]}',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            // Displaying the user who posted the request
                            'Posted by: ${userSnapshot.data!['name']}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text('Contact:'),
                          SizedBox(height: 5),
                          Row(
                            // Displaying social media icons for contacting
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  // Launch SMS app to send a message
                                  final Uri url = Uri(
                                    scheme: 'sms',
                                    path: phoneNumber,
                                  );
                                  if (await canLaunch(url.toString())) {
                                    await launch(url.toString());
                                  } else {
                                    print('Could not launch $url');
                                  }
                                },
                                child: Image.asset('images/message.png',
                                    width: 30, height: 30),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 0),
    );
  }
}