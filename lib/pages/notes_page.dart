import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../models/note.dart';
import '../services/api_service.dart';
import 'note_details_page.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class NotesPage extends StatefulWidget {
  final int courseId;
  final String courseTitle;
  final int userId;

  const NotesPage({Key? key, required this.courseId, required this.courseTitle, required this.userId}) : super(key: key);

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Note> _notes = [];
  bool _loading = true;
  File? _pickedImage;

  final TextEditingController _noteTitleController = TextEditingController();
  final TextEditingController _noteContentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getNotesByCourse(widget.courseId);
      if (data is List) {
        setState(() {
          _notes = data.map((e) => Note.fromJson(e)).toList();
        });
      } else {
        setState(() => _notes = []);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load notes')),
      );
      setState(() => _notes = []);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    if (kIsWeb || Platform.isLinux) {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _pickedImage = File(result.files.first.path!);
        });
      }
    } else if (Platform.isAndroid || Platform.isIOS) {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _createNote() async {
    final title = _noteTitleController.text.trim();
    final content = _noteContentController.text.trim();
    if (title.isEmpty || content.isEmpty) return;

    try {
      final response = await ApiService.createNote(
          widget.courseId,
          widget.userId,
          title,
          content,
          _pickedImage
      );

      if (response['success'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['success'])),
        );
        _noteTitleController.clear();
        _noteContentController.clear();
        setState(() => _pickedImage = null);
        await _loadNotes();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? 'Unknown error')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showCreateNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Note'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _noteTitleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: _noteContentController,
                  decoration: const InputDecoration(labelText: 'Content'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await _pickImage();
                    setDialogState(() {});
                  },
                  child: Text(_pickedImage == null ? 'Pick Image' : 'Change Image'),
                ),
                if (_pickedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.file(_pickedImage!, width: 100, height: 100, fit: BoxFit.cover),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _pickedImage = null);
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _createNote();
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteNote(int noteId) async {
    try {
      final response = await ApiService.deleteNote(noteId);
      if (response['success'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['success'])),
        );
        setState(() {
          _notes.removeWhere((note) => note.id == noteId);
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes - ${widget.courseTitle}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notes.isEmpty
          ? const Center(child: Text('No notes yet'))
          : ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          print('Loading image: ${note.fullImageUrl}');
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteDetailsPage(note: note),
                  ),
                );
                if (result == true) {
                  _loadNotes();
                }
              },
              leading: note.imageUrl.isNotEmpty
                  ? SecureNetworkImage(
                imageUrl: note.fullImageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
                  : const Icon(Icons.note),
              title: Text(note.title),
              subtitle: Text(
                note.content,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },

      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: _showCreateNoteDialog,
      ),
    );
  }
}

class SecureNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SecureNetworkImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    Key? key,
  }) : super(key: key);

  Future<Uint8List> _fetchImageBytes() async {
    try {
      final client = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;

      final request = await client.getUrl(Uri.parse(imageUrl));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('Failed to load image, Status: ${response.statusCode}');
      }

      return await consolidateHttpClientResponseBytes(response);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return const Icon(Icons.image_not_supported);

    if (kIsWeb) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.broken_image),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: FutureBuilder<Uint8List>(
        future: _fetchImageBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              width: width,
              height: height,
              fit: fit,
              gaplessPlayback: true,
            );
          } else if (snapshot.hasError) {
            return const Icon(Icons.broken_image);
          }

          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      ),
    );
  }
}
