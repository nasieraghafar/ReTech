import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  // StreamControllers for managing theme and font changes
  final StreamController<Color> _themeController =
      StreamController<Color>.broadcast(); // Broadcast stream to notify multiple listeners about theme changes
  final StreamController<String> _fontController =
      StreamController<String>.broadcast(); // Broadcast stream to notify multiple listeners about font changes
  SharedPreferences? _prefs; // Instance of SharedPreferences for persistent storage

  // Streams to expose theme and font changes
  Stream<Color> get themeStream => _themeController.stream; // Stream to listen to theme color changes
  Stream<String> get fontStream => _fontController.stream; // Stream to listen to font changes

  // Set the theme color and update the persistent storage
  void setTheme(Color color, String stringTheme) async {
    _themeController.add(color); // Notify listeners about the theme change
    if (_prefs != null) {
      await _prefs!.setString('selectedTheme', stringTheme); // Save theme to persistent storage
    }
    debugPrint('Theme: $stringTheme'); // Print the selected theme for debugging
  }

  // Set the font and update the persistent storage
  void setFont(String fontName) async {
    _fontController.add(fontName); // Notify listeners about the font change
    if (_prefs != null) {
      await _prefs!.setString('selectedFont', fontName); // Save font to persistent storage
    }
    debugPrint('Font: $fontName'); // Print the selected font for debugging
  }

  // Load the theme and font settings from persistent storage
  Future<void> loadTheme() async {
    _prefs = await SharedPreferences.getInstance(); // Initialize SharedPreferences instance
    Color currentTheme = Color.fromARGB(255, 75, 205, 80); // Default theme
    String currentFont = 'Roboto'; // Default font

    // Check if a theme is saved in persistent storage and apply it
    if (_prefs!.containsKey('selectedTheme')) {
      String? selectedTheme = _prefs!.getString('selectedTheme');
      if (selectedTheme == 'deepPurple') {
        currentTheme = Colors.deepPurple;
      } else if (selectedTheme == 'blue') {
        currentTheme = Colors.blue;
      } else if (selectedTheme == 'green') {
        currentTheme = Color.fromARGB(255, 75, 205, 80);
      } else if (selectedTheme == 'red') {
        currentTheme = Colors.red;
      }
    }

    // Check if a font is saved in persistent storage and apply it
    if (_prefs!.containsKey('selectedFont')) {
      currentFont = _prefs!.getString('selectedFont') ?? 'Roboto';
    }
    
    // Notify listeners with the loaded theme and font settings
    _themeController.add(currentTheme);
    _fontController.add(currentFont);
  }

  // Close the StreamControllers when they are no longer needed
  void dispose() {
    _themeController.close(); // Close the theme stream controller
    _fontController.close(); // Close the font stream controller
  }
}
