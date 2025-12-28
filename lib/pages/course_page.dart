import 'package:flutter/material.dart';
import '../models/course.dart';
import 'notes_page.dart';
import 'tasks_page.dart';
import 'terminologies_page.dart';

class CoursePage extends StatelessWidget {
  final Course course;
  final int userId;
  const CoursePage({Key? key, required this.course, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.note),
                title: const Text('Notes'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NotesPage(
                        courseId: course.id,
                        courseTitle: course.title,
                        userId: userId,
                      ),
                    ),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text('Tasks'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TasksPage(
                        courseId: course.id,
                        courseTitle: course.title,
                      ),
                    ),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.menu_book),
                title: const Text('Terminology'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TerminologyPage(
                        courseId: course.id,
                        courseTitle: course.title,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
