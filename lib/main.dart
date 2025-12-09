import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mbap_project/firebase_options.dart';
import 'package:mbap_project/screens/change_password_screen.dart';
import 'package:mbap_project/screens/create_screen.dart';
import 'package:mbap_project/screens/repair_details_screen.dart';
import 'package:mbap_project/screens/edit_screen.dart';
import 'package:mbap_project/screens/home_screen.dart';
import 'package:mbap_project/screens/own_repair_details_screen.dart';
import 'package:mbap_project/screens/profile_screen.dart';
import 'package:mbap_project/screens/register_screen.dart';
import 'package:mbap_project/screens/reset_password_screen.dart';
import 'package:mbap_project/screens/name_phonenumber_prompt.dart';
import 'package:mbap_project/screens/webview_screen.dart';
import 'package:mbap_project/services/firebase_service.dart';
import 'package:mbap_project/services/notifi_service.dart';
import 'package:mbap_project/services/themes_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Instance of GetIt for dependency injection
final GetIt getIt = GetIt.instance;

void setup() {
  // Register NotificationService as a singleton
  getIt.registerSingleton<NotificationService>(NotificationService());
}
void main() async {
  // Set up dependency injection
  setup();
  // Initialize time zones for scheduling notifications
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Detroit'));
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase with configuration options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Register FirebaseService and ThemeService as lazy singletons
  GetIt.instance.registerLazySingleton(() => FirebaseService());
  GetIt.instance.registerLazySingleton(() => ThemeService());
  // Request necessary permissions for notifications and exact alarms
  await requestNotificationPermission();
  await requestExactAlarmPermission();
  // Run the app
  runApp(MyApp());

}

// Request notification permission from the user
Future<void> requestNotificationPermission() async {
  if (await Permission.notification.request().isGranted) {
    // Notification permission granted
  }
}

// Request permission for scheduling exact alarms (Android 12+) 
Future<void> requestExactAlarmPermission() async {
  if (await Permission.scheduleExactAlarm.request().isGranted) {
    // Exact Alarm permission granted
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the ThemeService instance from GetIt
    final themeService = GetIt.instance<ThemeService>();
    themeService.loadTheme(); // Load the theme settings

    // Build the MaterialApp with theme and font updates
    return StreamBuilder<Color>(
      stream: themeService.themeStream,
      initialData: Color.fromARGB(255, 75, 205, 80), // Default theme color
      builder: (context, themeSnapshot) {
        final currentThemeColor =
            themeSnapshot.data ?? Color.fromARGB(255, 75, 205, 80);

        return StreamBuilder<String>(
          stream: themeService.fontStream,
          initialData: 'Roboto', // Default font
          builder: (context, fontSnapshot) {
            final currentFont = fontSnapshot.data ?? 'Roboto';

            // Configure MaterialApp with theme and routes
            return MaterialApp(
              routes: {
                RegisterScreen.routeName: (_) => RegisterScreen(),
                HomeScreen.routeName: (_) => HomeScreen(),
                CreateScreen.routeName: (_) => CreateScreen(),
                ProfileScreen.routeName: (_) => ProfileScreen(),
                DetailScreen.routeName: (_) => DetailScreen(),
                OwnDetailsScreen.routeName: (_) => OwnDetailsScreen(),
                EditScreen.routeName: (_) => EditScreen(),
                ResetPasswordScreen.routeName: (_) => ResetPasswordScreen(),
                ChangePasswordScreen.routeName: (_) => ChangePasswordScreen(),
                NamePhoneNumberPrompt.routeName: (_) => NamePhoneNumberPrompt(),
                WebViewScreen.routeName: (_) =>
                    WebViewScreen(url: 'https://www.example.com'),
              },
              theme: ThemeData(
                primarySwatch: _getMaterialColor(currentThemeColor),
                appBarTheme: AppBarTheme(
                  color: currentThemeColor, // Set the AppBar color based on the theme
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentThemeColor, // Button color
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    textStyle: TextStyle(fontFamily: currentFont), // Button text font
                  ),
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    textStyle: TextStyle(
                      fontFamily: currentFont, // TextButton text font
                    ),
                  ),
                ),
                iconTheme: IconThemeData(
                  color: currentThemeColor, // Icon color based on theme
                ),
                textTheme: TextTheme(
                  bodyText1: TextStyle(fontFamily: currentFont),
                  bodyText2: TextStyle(fontFamily: currentFont),
                  headline1: TextStyle(fontFamily: currentFont),
                  headline2: TextStyle(fontFamily: currentFont),
                  headline3: TextStyle(fontFamily: currentFont),
                  headline4: TextStyle(fontFamily: currentFont),
                  headline5: TextStyle(fontFamily: currentFont),
                  headline6: TextStyle(fontFamily: currentFont),
                  subtitle1: TextStyle(fontFamily: currentFont),
                  subtitle2: TextStyle(fontFamily: currentFont),
                ),
                useMaterial3: true, // Enable Material3 design
              ),
              home: MainScreen(), // Set MainScreen as the home screen
            );
          },
        );
      },
    );
  }

  // Helper function to create a MaterialColor from a given Color
  MaterialColor _getMaterialColor(Color color) {
    return MaterialColor(
      color.value,
      <int, Color>{
        50: color.withOpacity(0.1),
        100: color.withOpacity(0.2),
        200: color.withOpacity(0.3),
        300: color.withOpacity(0.4),
        400: color.withOpacity(0.5),
        500: color.withOpacity(0.6),
        600: color.withOpacity(0.7),
        700: color.withOpacity(0.8),
        800: color.withOpacity(0.9),
        900: color, // The actual color at full opacity
      },
    );
  }
}

class MainScreen extends StatelessWidget {
  static String routeName = '/';

  // Launch a URL using url_launcher package
  void _launchURL(String url) async {
    Uri urlUri = Uri.parse(url);

    if (await canLaunchUrl(urlUri)) {
      await launchUrl(urlUri); // Launch the URL if it can be handled
    } else {
      throw 'Could not launch $url'; // Handle the case where the URL cannot be launched
    }
  }

  final FirebaseService fbService = GetIt.instance<FirebaseService>(); // Get the FirebaseService instance from GetIt

  // Sign in with Google and handle navigation based on authentication result
  void signInWithGoogle(BuildContext context) async {
    try {
      final user = await fbService.signInWithGoogle(); // Attempt Google sign-in
      if (user != null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successfully!')), // Show success message
        );

        final userData = await fbService.getUserData(); // Retrieve user data
        if (userData == null) {
          Navigator.of(context).pushNamed(NamePhoneNumberPrompt.routeName); // Prompt user for name and phone number if not available
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
            HomeScreen.routeName, // Navigate to HomeScreen
            (Route<dynamic> route) => false, // Remove all previous routes
          );
        }
      }
    } catch (error) {
      FocusScope.of(context).unfocus(); // Dismiss keyboard on error
      String message = error.toString();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message))); // Show error message
    }
  }

  final TextEditingController _emailController = TextEditingController(); // Controller for email input
  final TextEditingController _passwordController = TextEditingController(); // Controller for password input

  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false); // Notifier for loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Column(
              children: [
                const SizedBox(height: 80),
                Image.asset('images/logo.png'),
                const SizedBox(height: 20),
                // Email text field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  ),
                ),
                const SizedBox(height: 10),
                // Password text field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  ),
                  obscureText: true, // Hide password text
                ),
                const SizedBox(height: 10),
                // Forgot Password button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(ResetPasswordScreen.routeName); // Navigate to reset password screen
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Login button with loading indicator
                ValueListenableBuilder<bool>(
                  valueListenable: _isLoading,
                  builder: (context, isLoading, child) {
                    return isLoading
                        ? Center(child: CircularProgressIndicator()) // Show loading indicator while logging in
                        : ElevatedButton(
                            onPressed: () async {
                              String email = _emailController.text;
                              String password = _passwordController.text;

                              if (email.isNotEmpty && password.isNotEmpty) {
                                _isLoading.value = true;
                                try {
                                  await GetIt.instance<FirebaseService>()
                                      .login(email, password); // Attempt login
                                  Navigator.of(context).pushReplacementNamed(
                                      HomeScreen.routeName); // Navigate to HomeScreen upon success
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Login failed. Please try again.')), // Show login error
                                  );
                                } finally {
                                  _isLoading.value = false; // Reset loading state
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Please enter both email and password.')), // Show validation error
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 75, 205, 80),
                              minimumSize: Size(200, 50),
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(7)), // Set button border radius
                              ),
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                  },
                ),
                const SizedBox(height: 10),
                // Sign in with Google button
                OutlinedButton(
                  onPressed: () => signInWithGoogle(context),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: Size(200, 50),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7)), // Set button border radius
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('images/google.png', height: 30, width: 30), // Google logo
                      const SizedBox(width: 10),
                      Text(
                        'Sign in with Google',
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ), // Adjusted spacing for better alignment
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WebViewScreen(
                            url: 'https://www.youtube.com/watch?v=-uyIzKIw0xY'), // Open a WebView with a specific URL
                      ),
                    );
                  },
                  child: Text(
                    'E-waste video',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Sign Up prompt
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(RegisterScreen.routeName); // Navigate to RegisterScreen
                      },
                      child: Text(
                        'Sign Up.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 75, 205, 80),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}