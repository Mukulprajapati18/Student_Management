// student_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  String id;
  String name;
  String className;
  Map<String, bool> attendance;

  Student({
    required this.id,
    required this.name,
    required this.className,
    this.attendance = const {},
  });

  // Add a fromJson factory method
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      className: json['className'] ?? '',
      attendance: Map<String, bool>.from(json['attendance'] ?? {}),
    );
  }
}

class StudentProvider extends ChangeNotifier {
  final List<Student> _students = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Student> get students => _students;

  Future<void> fetchStudents() async {
    final querySnapshot = await _firestore.collection('students').get();
    _students.clear();
    _students.addAll(querySnapshot.docs.map((doc) => Student.fromJson(doc.data() as Map<String, dynamic>)));
    notifyListeners();
  }

  Future<void> addStudent(Student student) async {
    _students.add(student);
    notifyListeners();

    // Add student to Firestore collection
    await _firestore.collection('students').doc(student.id).set({
      'id': student.id,
      'name': student.name,
      'className': student.className,
      'attendance': {}, // Initialize attendance as an empty map
    });
  }

  void markAttendance(String studentId, String date, bool isPresent) {
    final student = _students.firstWhere((s) => s.id == studentId);
    student.attendance[date] = isPresent;
    notifyListeners();
  }
}


class StudentManagementScreen extends StatelessWidget {
  const StudentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StudentProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Student Management'),
        ),
        body: Column(
          children: [
            _AddStudentForm(),
            _StudentList(),
          ],
        ),
      ),
    );
  }
}

class _AddStudentForm extends StatelessWidget {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FormBuilder(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Student',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FormBuilderTextField(
              name: 'id',
              decoration: const InputDecoration(labelText: 'Student ID'),
              validator: FormBuilderValidators.required(),
            ),
            FormBuilderTextField(
              name: 'name',
              decoration: const InputDecoration(labelText: 'Student Name'),
              validator: FormBuilderValidators.required(),
            ),
            FormBuilderTextField(
              name: 'className',
              decoration: const InputDecoration(labelText: 'Class Name'),
              validator: FormBuilderValidators.required(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _addStudent(context);
              },
              child: const Text('Add Student'),
            ),
          ],
        ),
      ),
    );
  }

  void _addStudent(BuildContext context) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      final id = formData['id'] as String;
      final name = formData['name'] as String;
      final className = formData['className'] as String;

      final studentProvider = Provider.of<StudentProvider>(
          context, listen: false);
      studentProvider.addStudent(
          Student(id: id, name: name, className: className));

      // Add student to Firestore collection
      await FirebaseFirestore.instance.collection('students').doc(id).set({
        'id': id,
        'name': name,
        'className': className,
        'attendance': {}, // Initialize attendance as an empty map
      });

      _formKey.currentState!.reset();
    }
  }
}

class _StudentList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);

    return Expanded(
      child: FutureBuilder(
        future: studentProvider.fetchStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Show a loading indicator while fetching data
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return _buildStudentList(context, studentProvider.students);
          }
        },
      ),
    );
  }

  Widget _buildStudentList(BuildContext context, List<Student> students) {
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return ListTile(
          title: Text('${student.name} (${student.className})'),
          trailing: _buildAttendanceCheckbox(context, student),
        );
      },
    );
  }

  Widget _buildAttendanceCheckbox(BuildContext context, Student student) {
    final currentDate = DateTime.now().toLocal().toString().split(' ')[0];

    return Checkbox(
      value: student.attendance[currentDate] ?? false,
      onChanged: (value) {
        _markAttendance(context, student.id, currentDate, value ?? false);
      },
    );
  }

  void _markAttendance(BuildContext context, String studentId, String date, bool isPresent) {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    studentProvider.markAttendance(studentId, date, isPresent);
  }

  void _searchStudents(BuildContext context) async {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final results = await showSearch(
      context: context,
      delegate: StudentSearchDelegate(studentProvider.students),
    );

    // Handle search results, if needed
  }
}

class StudentSearchDelegate extends SearchDelegate<String> {
  final List<Student> students;

  StudentSearchDelegate(this.students);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredStudents = students.where((student) =>
    student.name.toLowerCase().contains(query.toLowerCase()) ||
        student.className.toLowerCase().contains(query.toLowerCase()));

    return _buildSearchResults(context, filteredStudents.toList());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestedStudents = students.where((student) =>
    student.name.toLowerCase().contains(query.toLowerCase()) ||
        student.className.toLowerCase().contains(query.toLowerCase()));

    return _buildSearchResults(context, suggestedStudents.toList());
  }

  Widget _buildSearchResults(BuildContext context, List<Student> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final student = results[index];
        return ListTile(
          title: Text('${student.name} (${student.className})'),
          trailing: _buildAttendanceCheckbox(context, student),
        );
      },
    );
  }

  Widget _buildAttendanceCheckbox(BuildContext context, Student student) {
    final currentDate = DateTime.now().toLocal().toString().split(' ')[0];

    return Checkbox(
      value: student.attendance[currentDate] ?? false,
      onChanged: (value) {
        _markAttendance(context, student.id, currentDate, value ?? false);
      },
    );
  }

  void _markAttendance(BuildContext context, String studentId, String date, bool isPresent) {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    studentProvider.markAttendance(studentId, date, isPresent);
  }
}
