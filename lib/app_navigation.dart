import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'student_management_screen.dart';
import 'class_schedules_screen.dart';

class AppNavigation {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case '/student_management':
        return MaterialPageRoute(builder: (_) => const StudentManagementScreen());
      case '/class_schedules':
        return MaterialPageRoute(builder: (_) => const ClassSchedulesScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
