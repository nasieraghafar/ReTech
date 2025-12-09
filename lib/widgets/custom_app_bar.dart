import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mbap_project/services/themes_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  CustomAppBar({required this.title, this.actions});

  final ThemeService themeService = GetIt.instance<ThemeService>();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Color>(
      stream: themeService.themeStream,
      initialData: Color.fromARGB(255, 75, 205, 80), // Default theme color
      builder: (context, snapshot) {
        final currentThemeColor =
            snapshot.data ?? Color.fromARGB(255, 75, 205, 80);

        return AppBar(
          backgroundColor: currentThemeColor,
          title: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: actions,
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
