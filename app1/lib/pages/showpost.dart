import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:Eventlyst/utils/routes.dart';
import 'package:provider/provider.dart';
import 'package:Eventlyst/pages/notification_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Eventlyst/pages/FirestorePostDisplay.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class showpost extends StatelessWidget {
  final Map<String, dynamic> post;

  showpost({required this.post});

  String formatTime(dynamic time) {
    if (time is Timestamp) {
      return DateFormat('hh:mm a').format(time.toDate());
    } else if (time is String) {
      // Assuming that the time is in a specific format, adjust this accordingly
      // For example, if it's in 'HH:mm' format, you might use:
      // return DateFormat('HH:mm').format(DateTime.parse(time));
      return time; // Adjust this line based on the actual format of the time string
    } else {
      return 'Not specified';
    }
  }

  Future<void> registerUserForEvent(
    String eventId,
    String userId,
    String registrationDetails,
    BuildContext context,
  ) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Store registration
        await FirebaseFirestore.instance.collection('event_registrations').add({
          'post_id': eventId,
          'user_id': userId,
          'registration_details': registrationDetails,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Show a success message
        _showRegisterDialog(context);

        // Notify user
        Future.delayed(Duration(seconds: 2), () {
          Provider.of<NotificationProvider>(context, listen: false)
              .addNotification();
        });
      } else {
        // User is not authenticated, handle accordingly
        // You might want to redirect the user to the login screen
      }
    } catch (e) {
      print('Error registering for event: $e');
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to register for the event'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Change to your desired background color
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Eventlyst"),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, MyRoutes.remRoute);
            },
            icon: const Icon(Icons.notifications_none_sharp),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 5),
        // Wrap the contents with a SingleChildScrollView
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  post['title'] ?? 'Event Title',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  post['description'] ?? 'Event Description',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: post['image_url'] != null
                  ? Image.network(
                      post['image_url']!,
                      height: 300,
                      width: 300,
                      fit: BoxFit.cover,
                    )
                  : SizedBox
                      .shrink(), // This will occupy no space when image_url is null
            ),

            // this is for row format
            // Padding(
            //   padding: EdgeInsets.only(top: 20),
            //   child: Row(
            //     children: [
            //       Padding(
            //         padding: EdgeInsets.only(left: 30),
            //         child: Text(
            //           'Free : Free',
            //           style: TextStyle(
            //             fontSize: 16,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //       ),
            //       Padding(
            //         padding: EdgeInsets.only(left: 100),
            //         child: Text(
            //           post['selected_time'] ?? 'Event Timing',
            //           style: TextStyle(
            //             fontSize: 16,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // Padding(
            //   padding: EdgeInsets.only(top: 10),
            //   child: Row(
            //     children: [
            //       Column(
            //         children: [
            //           Padding(
            //             padding: EdgeInsets.only(left: 30),
            //             child: Text(
            //               'Venue : YCCE',
            //               style: TextStyle(
            //                 fontSize: 16,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //       Padding(
            //         padding: EdgeInsets.only(left: 80),
            //         child: Text(
            //           post['selected_date'] != null
            //               ? DateFormat('yyyy/MM/dd').format(
            //                   (post['selected_date'] as Timestamp).toDate())
            //               : 'Not specified',
            //           style: TextStyle(
            //             fontSize: 16,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Free: Free',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Venue: YCCE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Event Timing: ${post['selected_time'] != null ? formatTime(post['selected_time']) : 'Not specified'}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Event Date: ${post['selected_date'] != null ? DateFormat('yyyy/MM/dd').format((post['selected_date'] as Timestamp).toDate()) : 'Not specified'}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () async {
                  User? currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    // User is authenticated, proceed with registration
                    registerUserForEvent(
                      post['post_id'], // Replace with your actual event ID
                      currentUser.uid,
                      'Additional Registration Details',
                      context, // Pass the BuildContext
                    );
                  } else {
                    // User is not authenticated, handle accordingly
                    // You might want to redirect the user to the login screen
                  }
                },
                child: Text('Register now'),
              ),
            ),
          ],
        ),
      ),
      // Navigation bar
      bottomNavigationBar: Container(
        height: (MediaQuery.of(context).size.height * 0.1),
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: GNav(
            gap: 12,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.black,
            tabs: [
              GButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    MyRoutes.homeRoute,
                  );
                },
                icon: Icons.home,
              ),
              GButton(
                onPressed: () {
                  Navigator.pushNamed(context, MyRoutes.searchRoute);
                },
                icon: Icons.search,
              ),
              GButton(
                onPressed: () {
                  Navigator.pushNamed(context, MyRoutes.postRoute);
                },
                icon: Icons.post_add,
              ),
              GButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    MyRoutes.orgRoute,
                  );
                },
                icon: Icons.school,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRegisterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Registration Successful'),
          content: Text('You have successfully registered for the event.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class NotificationProvider extends ChangeNotifier {
  int _notificationCount = 0;

  int get notificationCount => _notificationCount;

  void addNotification() {
    _notificationCount++;
    notifyListeners();
  }
}
