import 'dart:convert';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class ApiService {
  static const String baseUrl = 'https://mindvault.atwebpages.com/api';

  static IOClient _getClient() {
    final ioc = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return IOClient(ioc);
  }

  static Future<List<dynamic>> getNotesByCourse(int courseId) async {
    final client = _getClient();
    final response = await client.post(
      Uri.parse('$baseUrl/notes.php'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'action': 'read', 'course_id': courseId}),
    ).timeout(const Duration(seconds: 10));

    final decoded = json.decode(response.body);

    if (decoded is List) {
      return decoded;
    }
    return [];
  }

  static Future<Map<String, dynamic>> createNote(int courseId, int userId, String title, String content, File? imageFile) async {
    var uri = Uri.parse('$baseUrl/notes.php');


    final client = _getClient();

    var request = http.MultipartRequest('POST', uri);

    request.fields['action'] = 'create';
    request.fields['course_id'] = courseId.toString();
    request.fields['user_id'] = userId.toString();
    request.fields['title'] = title;
    request.fields['content'] = content;

    if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));
    }


    final streamedResponse = await client.send(request).timeout(const Duration(seconds: 20));
    final response = await http.Response.fromStream(streamedResponse);

    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> deleteNote(int noteId) async {
    final client = _getClient();
    final response = await client.post(
      Uri.parse('$baseUrl/notes.php'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'action': 'delete',
        'id': noteId,
      }),
    ).timeout(const Duration(seconds: 10));
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final client = _getClient();
    final response = await client.post(
      Uri.parse('$baseUrl/register.php'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'name': name, 'email': email, 'password': password}),
    ).timeout(const Duration(seconds: 10));
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final client = _getClient();
    final response = await client.post(
      Uri.parse('$baseUrl/login.php'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'email': email, 'password': password}),
    ).timeout(const Duration(seconds: 10));
    return json.decode(response.body);
  }

  static Future<List<dynamic>> getNotes(int courseId) async {
    final client = _getClient();
    final response = await client.post(
      Uri.parse('$baseUrl/notes.php'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'action': 'read', 'course_id': courseId}),
    ).timeout(const Duration(seconds: 10));
    return json.decode(response.body);
  }

  static Future<List<dynamic>> getCourses(int userId) async {
    final client = _getClient();
    final response = await client.post(
      Uri.parse('$baseUrl/courses.php'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'action': 'read', 'user_id': userId}),
    ).timeout(const Duration(seconds: 10));
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> createCourse(int userId, String title, String description) async {
    final client = _getClient();
    final response = await client.post(
      Uri.parse('$baseUrl/courses.php'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'action': 'create',
        'user_id': userId,
        'title': title,
        'description': description,
      }),
    ).timeout(const Duration(seconds: 10));
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> deleteCourse(int courseId) async {
    final client = _getClient();
    final response = await client.post(
      Uri.parse('$baseUrl/courses.php'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'action': 'delete',
        'course_id': courseId,
      }),
    ).timeout(const Duration(seconds: 10));
    return json.decode(response.body);
  }

  static Future<List<dynamic>> getTasks(int courseId) async {
    final client = _getClient();
    final response = await client.post(
      Uri.parse('$baseUrl/tasks.php'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({'action': 'read', 'course_id': courseId}),
    ).timeout(const Duration(seconds: 10));
    return json.decode(response.body);
  }

  static Future<List<dynamic>> getTerminologies(int courseId) async {
    try {
      final client = _getClient();
      final response = await client.post(
        Uri.parse('$baseUrl/terminology.php'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({'action': 'read', 'course_id': courseId}),
      ).timeout(const Duration(seconds: 10));

      final decoded = json.decode(response.body);

      if (decoded is List) {
        return decoded;
      } else if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
        if (decoded['data'] is List) {
          return decoded['data'];
        }
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> createTerminology(int courseId, String term, String definition) async {
    final client = _getClient();
    final response = await client.post(
      Uri.parse('$baseUrl/terminology.php'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'action': 'create',
        'course_id': courseId,
        'term': term,
        'definition': definition,
      }),
    ).timeout(const Duration(seconds: 10));
    return json.decode(response.body);
  }

  static Future<List<dynamic>> getTasksByCourse(int courseId) async {
    try {
      final client = _getClient();
      final response = await client.post(
        Uri.parse('$baseUrl/tasks.php'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({'action': 'read', 'course_id': courseId}),
      ).timeout(const Duration(seconds: 10));

      final decoded = json.decode(response.body);
      if (decoded is List) {
        return decoded;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> createTask(int courseId, String title, String description, {String? deadlineDate}) async {
    final client = _getClient();
    final response = await client.post(
      Uri.parse('$baseUrl/tasks.php'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'action': 'create',
        'course_id': courseId,
        'title': title,
        'description': description,
        if (deadlineDate != null) 'deadline_date': deadlineDate,
      }),
    ).timeout(const Duration(seconds: 10));
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> deleteTask(int taskId) async {
    final client = _getClient();
    final response = await client.post(
      Uri.parse('$baseUrl/tasks.php'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'action': 'delete',
        'task_id': taskId,
      }),
    ).timeout(const Duration(seconds: 10));
    return json.decode(response.body);
  }
}