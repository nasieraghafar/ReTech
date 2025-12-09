import 'package:flutter/material.dart';
import 'package:mbap_project/main.dart';

class RegisterDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(10.0),
      ),
      title: Text('Registration Successful'),
      content: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Text('Back to Login', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
