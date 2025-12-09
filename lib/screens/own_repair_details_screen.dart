import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mbap_project/modals/repair_request1.dart';
import 'package:mbap_project/screens/edit_screen.dart';
import 'package:mbap_project/screens/profile_screen.dart';
import 'package:mbap_project/services/firebase_service.dart';
import 'package:mbap_project/widgets/nav_bar.dart';

class OwnDetailsScreen extends StatefulWidget {
  // Define the route name for navigating to this screen
  static String routeName = '/own_details';

  @override
  _OwnDetailsScreenState createState() => _OwnDetailsScreenState();
}

class _OwnDetailsScreenState extends State<OwnDetailsScreen> {
  // Get the instance of firebase service using getit for dependency injection
  final FirebaseService fbService = GetIt.instance<FirebaseService>(); 
  late Future<Requests> _requestDetails; // Future variable to hold the repair request details

  @override
  void didChangeDependencies() {
    super.didChangeDependencies(); // Retrieve the request id from the navigation arguments
    final String requestId =
        ModalRoute.of(context)!.settings.arguments as String;
    _requestDetails = fbService.getRequestById(requestId); // Fetch the request details using the firebase service
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar for the Own Details screen
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          'Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Requests>(
        future: _requestDetails, // Future to fetch repair request details
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Show loading indicator while waiting for data
          } else if (snapshot.hasError) {
            // Show error message if an error occurs
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            // Show message if no data is found
            return Center(child: Text('No data found'));
          } else { // If data is fetched successfully, display the details
            final Requests item = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network( // Display the image of repair request
                    item.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row( // Display the title and options button
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.more_vert,),
                              onPressed: () {
                                showModalBottomSheet( // Show bottom sheet edit and delete options
                                  context: context,
                                  builder: (context) {
                                    final themeColor = Theme.of(context).iconTheme.color ?? Colors.black;

                                    return Container(
                                      padding: EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile( // Edit request option
                                            leading: Icon(
                                              Icons.edit,
                                              color: themeColor,
                                            ),
                                            title: Text('Edit Request'),
                                            onTap: () {
                                              Navigator.pop(context);
                                              Navigator.pushNamed( // Navigate to the EditScreen to edit the request
                                                context,
                                                EditScreen.routeName,
                                                arguments: item,
                                              );
                                            },
                                          ),
                                          ListTile( // Delete request option
                                            leading: Icon(
                                              Icons.delete,
                                              color: themeColor,
                                            ),
                                            title: Text('Delete Request'),
                                            onTap: () {
                                              Navigator.pop(context);
                                              showDialog( // Show confirmation dialog before deleting
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    backgroundColor:
                                                        Colors.white,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    title:
                                                        Text('Confirm Delete?'),
                                                    actions: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(); // Close the dialog
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                          ),
                                                          backgroundColor:
                                                              Color.fromARGB(
                                                                  255,
                                                                  81,
                                                                  90,
                                                                  81),
                                                        ),
                                                        child: Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                          try { // Delete the request using firebase service
                                                            fbService
                                                                .deleteRequest(
                                                                    item.id);
                                                            ScaffoldMessenger // Show success message
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                    'Repair Request Deleted'),
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            1),
                                                              ),
                                                            );
                                                            Navigator.of( // Navigate to profile screen
                                                                    context)
                                                                .pushReplacementNamed(
                                                              ProfileScreen
                                                                  .routeName,
                                                            );
                                                          } catch (e) {
                                                            print(
                                                                'Error deleting request: $e');
                                                                // Show an error message if the deletion fails
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                    'Failed to delete request'),
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            1),
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          'Delete',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        // Display the details of the repair request
                        Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(item.detail),
                        SizedBox(height: 20),
                        Text( // Display the create date and device type
                          'Date: ${item.createDate.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Device: ${item.deviceType}',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 2),
    );
  }
}
