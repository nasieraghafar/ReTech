import 'package:flutter/material.dart';
import 'package:mbap_project/screens/profile_screen.dart';

class CreateDialog extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(10.0),
      ),
      title: Text('Repair Request Created'),
      content: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed(ProfileScreen.routeName); // Navigate to the profile screen
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Text('To Profile', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
