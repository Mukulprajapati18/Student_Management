// class_schedules_screen.dart
import 'package:flutter/material.dart';

class ClassSchedulesScreen extends StatelessWidget {
  const ClassSchedulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Schedules'),
      ),
      body: const Center(
        child: Text('Class Schedules Screen'),
      ),
    );
  }
}