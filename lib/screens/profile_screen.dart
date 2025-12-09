  import 'package:flutter/material.dart';
  import 'package:get_it/get_it.dart';
  import 'package:mbap_project/modals/repair_request1.dart';
  import 'package:mbap_project/services/firebase_service.dart';
  import 'package:mbap_project/services/themes_service.dart';
  import 'package:mbap_project/widgets/logout_dialog.dart';
  import 'package:mbap_project/widgets/nav_bar.dart';
  import 'package:mbap_project/screens/change_password_screen.dart';
  import 'package:mbap_project/screens/own_repair_details_screen.dart';
  import 'package:share_plus/share_plus.dart';

  class ProfileScreen extends StatelessWidget {
    // Define the route name for navigating to this screen
    static String routeName = '/profile';

    final FirebaseService fbService = GetIt.instance<FirebaseService>(); // Get FirebaseService instance for data operations
    final ThemeService themeService = GetIt.instance<ThemeService>(); // Get ThemeService instance for theme management

    @override
    Widget build(BuildContext context) {
      return StreamBuilder<Color>(
        // StreamBuilder to listen for theme color changes
        stream: themeService.themeStream,
        builder: (context, snapshot) {
          // Get the current theme color or use a default color if none is provided
          final themeColor = snapshot.data ?? Color.fromARGB(255, 75, 205, 80);
          return Scaffold(
            // AppBar for the Profile screen
            appBar: AppBar(
              automaticallyImplyLeading: false, // Do not show the default leading icon
              title: Text(
                'Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                // Button to share app invitation
                icon: Icon(Icons.share),
                color: Colors.white,
                onPressed: () {
                  Share.share(
                    'Download the ReTech app to help save the environment by reducing e-waste!',
                    subject: 'ReTech App Invitation',
                  );
                },
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  // Button to show logout dialog
                  icon: Icon(Icons.logout),
                  color: Colors.white,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return LogoutDialog(); // Show a dialog asking for logout confirmation
                      },
                    );
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<String>(
                // StreamBuilder listens to changes in font settings
                stream: themeService.fontStream,
                initialData: 'Roboto',
                builder: (context, fontSnapshot) {
                  // Get the current font or use a default font if none is provided
                  final font = fontSnapshot.data ?? 'Roboto';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<Map<String, dynamic>?>(
                        // FutureBuilder to get user data
                        future: fbService.getUserData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            // Show loading indicator while waiting for user data
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            // Show loading indicator while waiting for data
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }
                          if (!snapshot.hasData || snapshot.data == null) {
                            // Show loading indicator while waiting for data
                            return Center(child: Text('User data not found.'));
                          }

                          final userData = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData['name'] ?? 'Name not available',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 1),
                              Text(
                                userData['email'] ?? 'Email not available',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                userData['phoneNumber'] ?? 'Phone number not available',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                // Row containing buttons for changing password and font
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      // Navigate to change password screen
                                      Navigator.of(context).pushNamed(ChangePasswordScreen.routeName);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                    ),
                                    child: Text('Change Password'),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Show dialog to select a font
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return FontChangeDialog(); // Display the font change dialog
                                        },
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                    ),
                                    child: Text('Change Font'),
                                  ),
                                ],
                              ),
                              ListTile(
                                leading: const Icon(Icons.palette),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // Color options for theme selection
                                    GestureDetector(
                                      child: CircleAvatar(
                                        backgroundColor: Colors.deepPurple, 
                                        maxRadius: 15,
                                      ),
                                      onTap: () {
                                        themeService.setTheme(Colors.deepPurple, 'deepPurple'); // Set theme color and name
                                      },
                                    ),
                                    SizedBox(width: 8),
                                    GestureDetector(
                                      child: CircleAvatar(
                                        backgroundColor: Colors.blue,
                                        maxRadius: 15,
                                      ),
                                      onTap: () {
                                        themeService.setTheme(Colors.blue, 'blue'); // Set theme color and name
                                      },
                                    ),
                                    SizedBox(width: 8),
                                    GestureDetector(
                                      child: CircleAvatar(
                                        backgroundColor: Color.fromARGB(255, 75, 205, 80),
                                        maxRadius: 15,
                                      ),
                                      onTap: () {
                                        themeService.setTheme(Color.fromARGB(255, 75, 205, 80), 'green'); // Set theme color and name
                                      },
                                    ),
                                    SizedBox(width: 8),
                                    GestureDetector(
                                      child: CircleAvatar(
                                        backgroundColor: Colors.red,
                                        maxRadius: 15,
                                      ),
                                      onTap: () {
                                        themeService.setTheme(Colors.red, 'red'); // Set theme color and name
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Your Repair Requests',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: StreamBuilder<List<Requests>>(
                          // StreamBuilder to get list of repair requests
                          stream: fbService.getRequests(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              // Show loading indicator while waiting for data
                              return Center(child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              // Show error message if an error occurs
                              return Center(child: Text('Error: ${snapshot.error}'));
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              // Show message if no repair requests are found
                              return Center(child: Text('No repair requests found.'));
                            }

                            List<Requests> repairRequests = snapshot.data!;

                            return GridView.builder(
                              // Grid view to display repair requests
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: repairRequests.length,
                              itemBuilder: (context, index) {
                                final item = repairRequests[index];
                                return GestureDetector(
                                  onTap: () {
                                    // Navigate to details screen of the selected request
                                    Navigator.of(context).pushNamed(
                                      OwnDetailsScreen.routeName,
                                      arguments: item.id,
                                    );
                                  },
                                  child: Card(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8.0),
                                            child: FadeInImage.assetNetwork(
                                              placeholder: 'images/placeholder.png',
                                              image: item.imageUrl,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                              imageErrorBuilder: (context, error, stackTrace) => Center(child: CircularProgressIndicator()),
                                              placeholderErrorBuilder: (context, error, stackTrace) => Center(child: CircularProgressIndicator()),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Date: ${item.createDate.toLocal().toString().split(' ')[0]}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                item.title,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            bottomNavigationBar: CustomBottomNavBar(
              currentIndex: 2,
            ),
          );
        },
      );
    }
  }

  // Dialog to select a font
  class FontChangeDialog extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
      final themeService = GetIt.instance<ThemeService>(); // Get ThemeService instance for font management

      return AlertDialog(
        title: Text('Select Font'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Roboto'),
              onTap: () {
                themeService.setFont('Roboto'); // Set selected font and close dialog
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text('Atma'),
              onTap: () {
                themeService.setFont('Atma'); // Set selected font and close dialog
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }