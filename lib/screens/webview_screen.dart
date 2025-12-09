import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
 
class WebViewScreen extends StatelessWidget {
  final String url; // URL to load in the WebView
  static String routeName = '/webview'; // Define the route name for navigation
 
  // Constructor to receive the URL to display
  WebViewScreen({required this.url});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white, // Set the text color in the AppBar
        title: Text('WebView', style: TextStyle(fontWeight: FontWeight.bold),), // Make the title text bold
      ),
      body: WebView(
        initialUrl: url, // Set the initial URL to be loaded in the WebView
        javascriptMode: JavascriptMode.unrestricted, // Allow JavaScript execution in the WebView
      ),
    );
  }
}