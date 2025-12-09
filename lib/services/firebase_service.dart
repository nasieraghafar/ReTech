import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mbap_project/modals/repair_request1.dart';
import 'package:path/path.dart';

class FirebaseService {
  // Method to reauthenticate the current user with their current password
  Future<void> reauthenticate(String currentPassword) async {
    User? user = FirebaseAuth.instance.currentUser; // Get the currently logged-in user
    if (user != null) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential); // Reauthenticate the user
      } catch (e) {
        throw e; // Rethrow exception if reauthentication fails
      }
    } else {
      throw Exception('No user is logged in.'); // Throw exception if no user is logged in
    }
  }

  // Method to change the password of the current user
  Future<void> changePassword(String newPassword) async {
    User? user = FirebaseAuth.instance.currentUser; // Get the currently logged-in user
    if (user != null) {
      try {
        await user.updatePassword(newPassword); // Update the user's password
      } catch (e) {
        throw e; // Rethrow exception if password change fails
      }
    } else {
      throw Exception('No user is logged in.'); // Throw exception if no user is logged in
    }
  }

  // Method to get the data of the currently logged-in user
  Future<Map<String, dynamic>?> getUserData() async {
    User? user = getCurrentUser(); // Get the currently logged-in user
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid) // Retrieve user data from Firestore
          .get();
      return doc.data() as Map<String, dynamic>?; // Return user data
    }
    return null; // Return null if user is not logged in
  }

  // Method to get the currently logged-in user
  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser; // Retrieve the currently logged-in user
  }

  // Method to register a new user with email, password, name, and phone number
  Future<void> register(
      String email, String password, String name, String phoneNumber) async {
    // Create a new user with email and password
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    User? user = userCredential.user; // Get the newly created user
    if (user != null) {
      // Save additional user details in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': email,
        'name': name,
        'phoneNumber': phoneNumber,
      });
    }
  }

  // Method to log in a user with email and password
  Future<UserCredential> login(email, password) {
    // Sign in with email and password
    return FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
  }

  // Method to send a password reset email
  Future<void> forgotPassword(email) {
    // Send a password reset email
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  // Stream to listen to authentication state changes
  Stream<User?> getAuthUser() {
    return FirebaseAuth.instance.authStateChanges(); // Stream of authentication state changes
  }

  // Method to log out the current user from both Google and Firebase
  Future<void> logOut() async {
    await GoogleSignIn().signOut(); // Sign out from Google
    return FirebaseAuth.instance.signOut(); // Sign out from Firebase
  }

  // Method to upload a receipt photo to Firebase Storage and return its download URL
  Future<String?> addReceiptPhoto(File receiptPhoto) {
    return FirebaseStorage.instance
        .ref()
        .child(DateTime.now().toString() + '_' + basename(receiptPhoto.path)) // Generate a unique file name
        .putFile(receiptPhoto) // Upload the file
        .then((task) {
      return task.ref.getDownloadURL().then((imageUrl) {
        return imageUrl; // Return the download URL of the uploaded photo
      });
    });
  }

  // Method to edit an existing receipt photo by deleting the old one and uploading a new one
  Future<String?> editReceiptPhoto(
      File receiptPhoto, String existingFileUrl) async {
    try {
      String existingFilePath =
          FirebaseStorage.instance.refFromURL(existingFileUrl).fullPath; // Get the path of the existing file

      await FirebaseStorage.instance.ref(existingFilePath).delete(); // Delete the old photo

      String newFilePath =
          DateTime.now().toString() + '_' + basename(receiptPhoto.path); // Generate a unique file name for the new photo
      TaskSnapshot task =
          await FirebaseStorage.instance.ref(newFilePath).putFile(receiptPhoto); // Upload the new photo

      String imageUrl = await task.ref.getDownloadURL(); // Get and return the download URL of the new photo
      return imageUrl;
    } catch (e) {
      print('Error editing receipt photo: $e'); // Log error if editing fails
      return null;
    }
  }

  // Method to add a new repair request to Firestore
  Future<void> addRequest(String title, String deviceType, String detail,
      String imageUrl, DateTime createDate) {
    List<String> keywords = generateKeywords(title); // Generate keywords for searching

    return FirebaseFirestore.instance.collection('repair_request').add({
      'email': getCurrentUser()!.email, // Store the email of the user who created the request
      'imageUrl': imageUrl,
      'title': title,
      'title_lowercase': title.toLowerCase(),
      'title_keywords': keywords, // Store generated keywords for searching
      'deviceType': deviceType,
      'detail': detail,
      'createDate': createDate,
    });
  }

  // Stream to get all repair requests of the current user
  Stream<List<Requests>> getRequests() {
    return FirebaseFirestore.instance
        .collection('repair_request')
        .where('email', isEqualTo: getCurrentUser()!.email) // Filter by current user's email
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Requests(
          id: doc.id,
          imageUrl: data['imageUrl'] ?? '',
          title: data['title'] ?? '',
          deviceType: data['deviceType'] ?? '',
          detail: data['detail'] ?? '',
          createDate: (data['createDate'] as Timestamp).toDate(), // Convert Timestamp to DateTime
          email: data['email'] ?? '',
        );
      }).toList(); // Convert Firestore documents to Requests objects
    });
  }

  // Method to update an existing repair request
  Future<void> updateRequest(String imageUrl, String id, String title,
      String deviceType, String detail, DateTime createDate) {
    List<String> keywords = generateKeywords(title); // Generate keywords for searching

    return FirebaseFirestore.instance
        .collection('repair_request')
        .doc(id)
        .update({
      'imageUrl': imageUrl,
      'title': title,
      'title_lowercase': title.toLowerCase(),
      'title_keywords': keywords, // Store generated keywords for searching
      'detail': detail,
      'deviceType': deviceType,
      'createDate': createDate,
    });
  }

  // Method to delete a repair request
  Future<void> deleteRequest(String id) {
    return FirebaseFirestore.instance
        .collection('repair_request')
        .doc(id)
        .delete(); // Delete the specified repair request
  }

  // Method to get the image URL of a repair request by its ID
  Future<String> getImageUrlById(String id) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('repair_request')
        .doc(id)
        .get(); // Retrieve the document by its ID
    return doc['imageUrl'] ?? ''; // Return the image URL or an empty string if not found
  }

  // Method to get a repair request by its ID
  Future<Requests> getRequestById(String id) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('repair_request')
        .doc(id)
        .get(); // Retrieve the document by its ID
    return Requests(
      id: doc.id,
      imageUrl: doc['imageUrl'] ?? '',
      title: doc['title'] ?? '',
      deviceType: doc['deviceType'] ?? '',
      detail: doc['detail'] ?? '',
      createDate: (doc['createDate'] as Timestamp).toDate(), // Convert Timestamp to DateTime
      email: doc['email'] ?? '',
    );
  }

  // Stream to get filtered and searched repair requests
  Stream<List<Requests>> getFilteredRequests(
      String? filter, String searchQuery) {
    Query query = FirebaseFirestore.instance.collection('repair_request');

    if (filter != null && filter != 'Any') {
      query = query.where('deviceType', isEqualTo: filter); // Apply deviceType filter if provided
    }

    if (searchQuery.isNotEmpty) {
      String lowerSearchQuery = searchQuery.toLowerCase();
      query = query.where('title_keywords', arrayContains: lowerSearchQuery); // Apply search query filter
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          return Requests(
            id: doc.id,
            imageUrl: data['imageUrl'] ?? '',
            title: data['title'] ?? '',
            deviceType: data['deviceType'] ?? '',
            detail: data['detail'] ?? '',
            createDate: (data['createDate'] as Timestamp).toDate(), // Convert Timestamp to DateTime
            email: data['email'] ?? '',
          );
        } else {
          return Requests(
            id: doc.id,
            imageUrl: '',
            title: '',
            deviceType: '',
            detail: '',
            createDate: DateTime.now(),
            email: '',
          );
        }
      }).toList(); // Convert Firestore documents to Requests objects
    });
  }

  // Method to generate keywords from a title for searching
  List<String> generateKeywords(String title) {
    List<String> keywords = [];
    for (int start = 0; start < title.length; start++) {
      for (int end = start + 1; end <= title.length; end++) {
        String substring = title.substring(start, end).toLowerCase();
        keywords.add(substring);
      }
    }
    return keywords; // Return the list of keywords
  }

  // Method to sign in a user with Google account
  Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithPopup(googleProvider); // Sign in with Google on web

      return userCredential.user; // Return the signed-in user
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn(); // Sign in with Google on mobile
      if (googleUser == null) {
        return null; // Return null if user cancels sign-in
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential); // Sign in with the Google credential
      return userCredential.user; // Return the signed-in user
    }
  }

  // Method to sign out the current Google user
  Future<void> signOutGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut(); // Sign out from Google
  }

  // Method to get user data by their email address
  Future<Map<String, dynamic>?> getUserDataByEmail(String email) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email) // Query user by email
          .limit(1)
          .get()
          .then((snapshot) => snapshot.docs.first); // Retrieve the first matching document

      return doc.data() as Map<String, dynamic>?; // Return the user data
    } catch (e) {
      print('Error fetching user data: $e'); // Log error if fetching fails
      return null; // Return null if fetching fails
    }
  }
}
