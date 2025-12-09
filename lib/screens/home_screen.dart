import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mbap_project/modals/repair_request1.dart';
import 'package:mbap_project/services/firebase_service.dart';
import 'package:mbap_project/widgets/nav_bar.dart';
import 'package:mbap_project/screens/repair_details_screen.dart';

class HomeScreen extends StatefulWidget {
  // Define the route name for navigating to this screen
  static String routeName = '/home';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Get an instance of FirebaseService using GetIt for dependency injection
  final FirebaseService fbService = GetIt.instance<FirebaseService>();
  // Variable to hold the selected filter value
  String selectedFilter = 'Any';
  // Controller for the search text field
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Center the title in the AppBar
        title: TextField(
          controller: searchController, // Controller to manage the text field value
          onChanged: (value) {
            setState(() {}); // Refresh the UI when the search text changes
          },
          decoration: InputDecoration(
            hintText: 'Search', // Hint text for the search field
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.0),
              borderRadius: BorderRadius.zero,
            ),
            prefixIcon: Icon(Icons.search), // Icon for the search field
            contentPadding: EdgeInsets.symmetric(horizontal: 15.0), // Padding inside the search field
          ),
        ),
        automaticallyImplyLeading: false, // Do not automatically add a back button
        backgroundColor: Colors.white, // Set the background color to white
        elevation: 0, // Optional: Remove the shadow under the AppBar
      ),
      body: Column(
        children: [
          SizedBox(height: 20), // Add spacing at the top
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedFilter =
                        selectedFilter == 'Phone' ? 'Any' : 'Phone';
                  });
                },
                child: Image.asset('images/phones.png', width: 70, height: 70),
              ),
              // GestureDetector for filtering by Laptop
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedFilter =
                        selectedFilter == 'Laptop' ? 'Any' : 'Laptop';
                  });
                },
                child: Image.asset('images/laptops.png', width: 70, height: 70),
              ),
              // GestureDetector for filtering by TV
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedFilter = selectedFilter == 'TV' ? 'Any' : 'TV';
                  });
                },
                child: Image.asset('images/tv.png', width: 70, height: 70),
              ),
              // GestureDetector for filtering by Desktop
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedFilter =
                        selectedFilter == 'Desktop' ? 'Any' : 'Desktop';
                  });
                },
                child: Image.asset('images/desktop.png', width: 70, height: 70),
              ),
            ],
          ),
          SizedBox(height: 30), // Add spacing between filter and category text
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Text('Current Category: $selectedFilter',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: 20), // Add spacing before the list of repair requests
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: StreamBuilder<List<Requests>>(
                // Stream to listen for changes in filtered repair requests
                stream: fbService.getFilteredRequests(
                    selectedFilter, searchController.text),
                builder: (context, snapshot) {
                  // Display a loading indicator while waiting for data
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  // Display an error message if an error occurs
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  // Display a message if no repair requests are found
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No repair requests found.'));
                  }

                  List<Requests> filteredItems = snapshot.data!;

                  // GridView to display repair requests in a grid format
                  return GridView.builder(
                    itemCount: filteredItems.length, // Number of items in the grid
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of columns in the grid
                      mainAxisSpacing: 10.0, // Space between rows
                      crossAxisSpacing: 10.0, // Space between columns
                      childAspectRatio: 0.75, // Aspect ratio for each grid item
                    ),
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            DetailScreen.routeName,
                            arguments: item.id, // Navigate to detail screen with item ID
                          );
                        },
                        child: Card(
                          // Color and elevation can be adjusted for the card
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0), // Round the corners of the image
                                  child: FadeInImage.assetNetwork(
                                    placeholder: 'images/placeholder.png', // Placeholder image while loading
                                    image: item.imageUrl, // Image URL of the repair request
                                    fit: BoxFit.cover, // Fit the image within the container
                                    width: double.infinity,
                                    height: double.infinity,
                                    imageErrorBuilder:
                                        (context, error, stackTrace) => Center(
                                      child: CircularProgressIndicator(), // Show loading indicator on image error
                                    ),
                                    placeholderErrorBuilder:
                                        (context, error, stackTrace) => Center(
                                      child: CircularProgressIndicator(), // Show loading indicator on placeholder error
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Display the date of the repair request
                                    Text(
                                      'Date: ${item.createDate.toLocal().toString().split(' ')[0]}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(height: 5),
                                    // Display the title of the repair request
                                    Text(
                                      item.title,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5),
                                    // Display the device type of the repair request
                                    Text(
                                      'Device: ${item.deviceType}',
                                      style: TextStyle(fontSize: 12),
                                    ),
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
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 0),
    );
  }
}