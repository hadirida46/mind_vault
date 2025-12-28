import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/course.dart';
import 'course_page.dart';

class HomePage extends StatefulWidget {
  final int userId;
  final String userName;

  const HomePage({Key? key, required this.userId, required this.userName}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Course> _courses = [];
  bool _loading = true;
  final TextEditingController _courseTitleController = TextEditingController();
  final TextEditingController _courseDescController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getCourses(widget.userId);
      setState(() {
        _courses = data.map((e) => Course.fromJson(e)).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load courses')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _createCourse() async {
    final title = _courseTitleController.text.trim();
    final description = _courseDescController.text.trim();

    if (title.isEmpty || description.isEmpty) return;

    try {
      final response = await ApiService.createCourse(widget.userId, title, description);
      if (response['success'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['success'])),
        );
        _courseTitleController.clear();
        _courseDescController.clear();
        _loadCourses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? 'Unknown error')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection error')),
      );
    }
  }

  Future<void> _deleteCourse(int courseId) async {
    try {
      final response = await ApiService.deleteCourse(courseId);
      if (response['success'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['success'])),
        );
        _loadCourses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? 'Unknown error')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connection error')),
      );
    }
  }

  void _showCreateCourseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Course'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _courseTitleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: _courseDescController, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () { Navigator.pop(context); _createCourse(); }, child: const Text('Create')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MindVault - ${widget.userName}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
          ? const Center(child: Text('No courses yet'))
          : ListView.builder(
        itemCount: _courses.length,
        itemBuilder: (context, index) {
          final course = _courses[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(course.title),
              subtitle: Text(course.description),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteCourse(course.id),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CoursePage(course: course, userId: widget.userId),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: _showCreateCourseDialog,
      ),
    );
  }
}
