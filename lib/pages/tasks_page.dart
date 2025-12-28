import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TasksPage extends StatefulWidget {
  final int courseId;
  final String courseTitle;

  const TasksPage({Key? key, required this.courseId, required this.courseTitle}) : super(key: key);

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  List<Task> _tasks = [];
  bool _loading = true;
  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _taskDescController = TextEditingController();
  DateTime? _selectedDeadline;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getTasksByCourse(widget.courseId);
      setState(() {
        _tasks = data.map((e) => Task.fromJson(e)).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load tasks')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _createTask() async {
    final title = _taskTitleController.text.trim();
    final description = _taskDescController.text.trim();
    if (title.isEmpty || description.isEmpty) return;

    try {
      final response = await ApiService.createTask(
        widget.courseId,
        title,
        description,
        deadlineDate: _selectedDeadline?.toIso8601String().split('T')[0],
      );
      if (response['success'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['success'])),
        );
        _taskTitleController.clear();
        _taskDescController.clear();
        _selectedDeadline = null;
        _loadTasks();
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

  Future<void> _deleteTask(int taskId) async {
    try {
      final response = await ApiService.deleteTask(taskId);
      if (response['success'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['success'])),
        );
        _loadTasks();
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

  void _showCreateTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _taskTitleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: _taskDescController, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDeadline ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => _selectedDeadline = picked);
                }
              },
              child: Text(_selectedDeadline == null
                  ? 'Pick Deadline'
                  : 'Deadline: ${_selectedDeadline!.toLocal()}'.split(' ')[0]),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () { _selectedDeadline = null; Navigator.pop(context); }, child: const Text('Cancel')),
          ElevatedButton(onPressed: () { Navigator.pop(context); _createTask(); }, child: const Text('Create')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tasks - ${widget.courseTitle}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
          ? const Center(child: Text('No tasks yet'))
          : ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(task.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.description),
                  if (task.deadlineDate != null)
                    Text('Deadline: ${task.deadlineDate}'),
                ],
              ),
              onLongPress: () => _deleteTask(task.id),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: _showCreateTaskDialog,
      ),
    );
  }
}
