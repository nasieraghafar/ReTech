import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mbap_project/services/firebase_service.dart';
import 'package:mbap_project/main.dart';

class LogoutDialog extends StatelessWidget {
  final FirebaseService fbService = GetIt.instance<FirebaseService>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      title: Text('Confirm Logout?'),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            backgroundColor: Color.fromARGB(255, 81, 90, 81),
          ),
          child: Text('No', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await fbService.logOut(); // Call the logOut method

            // Use a microtask to delay navigation until after the current widget is disposed
            Future.microtask(() {
              Navigator.of(context).pushReplacementNamed(MainScreen.routeName);
            });
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Text('Yes', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
