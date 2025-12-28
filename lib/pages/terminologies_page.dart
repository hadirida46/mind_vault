import 'package:flutter/material.dart';
import '../models/term.dart';
import '../services/api_service.dart';

class TerminologyPage extends StatefulWidget {
  final int courseId;
  final String courseTitle;

  const TerminologyPage({
    Key? key,
    required this.courseId,
    required this.courseTitle,
  }) : super(key: key);

  @override
  _TerminologyPageState createState() => _TerminologyPageState();
}

class _TerminologyPageState extends State<TerminologyPage> {
  List<Term> _terms = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getTerminologies(widget.courseId);
      setState(() {
        _terms = data.map<Term>((e) => Term.fromJson(e)).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load terminologies')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showAddTermDialog() {
    final termController = TextEditingController();
    final definitionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Term'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: termController,
              decoration: const InputDecoration(labelText: 'Term'),
            ),
            TextField(
              controller: definitionController,
              decoration: const InputDecoration(labelText: 'Definition'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final term = termController.text.trim();
              final definition = definitionController.text.trim();

              if (term.isEmpty || definition.isEmpty) return;

              Navigator.pop(context);

              try {
                await ApiService.createTerminology(
                  widget.courseId,
                  term,
                  definition,
                );
                _loadTerms();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to create term')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.courseTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _terms.isEmpty
          ? const Center(child: Text('No terms yet'))
          : ListView.builder(
        itemCount: _terms.length,
        itemBuilder: (context, index) {
          final term = _terms[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(term.term),
              subtitle: Text(term.definition),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTermDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
