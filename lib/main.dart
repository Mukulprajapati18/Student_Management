import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app_navigation.dart';
void main() async {
  // Initialize Firebase (ensure you have added the firebase_core and cloud_firestore dependencies)
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'School Management App',
      initialRoute: '/',
      onGenerateRoute: AppNavigation.generateRoute,
      home: HomeScreen(), // Assume you have a HomeScreen as your starting point
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to Dashboard
                Navigator.pushNamed(context, '/');
              },
              child: const Text('Go to Dashboard'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to Student Management
                Navigator.pushNamed(context, '/student_management');
              },
              child: const Text('Go to Student Management'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to Class Schedules
                Navigator.pushNamed(context, '/class_schedules');
              },
              child: const Text('Go to Class Schedules'),
            ),
          ],
        ),
      ),
    );
  }
}
