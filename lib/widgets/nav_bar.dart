import 'package:flutter/material.dart';
import 'package:mbap_project/screens/create_screen.dart';
import 'package:mbap_project/screens/home_screen.dart';
import 'package:mbap_project/screens/profile_screen.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;

  CustomBottomNavBar({required this.currentIndex});

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {

  Color _getIconColor(int index) {
    return index == widget.currentIndex ? Colors.deepPurple : Colors.grey;
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, CreateScreen.routeName);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, ProfileScreen.routeName);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: _onItemTapped,
      backgroundColor: Colors.white, // Set the background color to white
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: _getIconColor(0)),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle, color: _getIconColor(1)),
          label: 'Create',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle, color: _getIconColor(2)),
          label: 'Profile',
        ),
      ],
    );
  }
}
