import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';

// Dart concept demonstration:
// - Form validation (validator functions with conditional checks)
// - Ternary operators for Create vs Edit mode
// - Asynchronous save method

class NoteEditorScreen extends StatefulWidget {
  final Note? existingNote;

  const NoteEditorScreen({super.key, this.existingNote});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final StorageService _storage = StorageService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  String _selectedSubject = 'General';
  String _selectedCategory = 'General';

  final List<String> _subjects = [
    'General',
    'Algorithms (CS401)',
    'Deep Learning (AI402)',
    'DBMS (CS403)',
    'Mobile Dev (SE404)',
    'Cloud Computing (EL405)',
  ];

  final List<String> _categories = [
    'General',
    'Lecture Notes',
    'Exam Prep',
    'Lab Summary',
    'Cheatsheet',
  ];

  bool get _isEditing => widget.existingNote != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.existingNote?.title ?? '');
    _descriptionController = TextEditingController(text: widget.existingNote?.description ?? '');
    if (widget.existingNote != null && _subjects.contains(widget.existingNote!.subject)) {
      _selectedSubject = widget.existingNote!.subject;
    }
    if (widget.existingNote != null && _categories.contains(widget.existingNote!.category)) {
      _selectedCategory = widget.existingNote!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (_isEditing) {
      final updated = widget.existingNote!.copyWith(
        title: title,
        subject: _selectedSubject,
        category: _selectedCategory,
        description: description,
      );
      await _storage.updateNote(updated);
    } else {
      final newNote = Note(
        id: 'note_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        subject: _selectedSubject,
        category: _selectedCategory,
        description: description,
        createdAt: DateTime.now(),
      );
      await _storage.addNote(newNote);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Note updated successfully!' : 'Note saved successfully!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Note' : 'Create New Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppTheme.primaryBlue),
            tooltip: 'Save Note',
            onPressed: _saveNote,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Subject Selection & Category Selection
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSubject,
                    decoration: const InputDecoration(
                      labelText: 'Course / Subject',
                      prefixIcon: Icon(Icons.book_outlined, color: AppTheme.primaryBlue),
                    ),
                    items: _subjects.map((sub) {
                      return DropdownMenuItem(value: sub, child: Text(sub, overflow: TextOverflow.ellipsis));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedSubject = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.folder_outlined, color: AppTheme.primaryBlue),
                    ),
                    items: _categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat, overflow: TextOverflow.ellipsis));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Note Title',
                hintText: 'e.g., Dynamic Programming Cheat Sheet',
                prefixIcon: Icon(Icons.title, color: AppTheme.primaryBlue),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter a note title';
                }
                if (val.trim().length < 3) {
                  return 'Title must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Content Body Field
            TextFormField(
              controller: _descriptionController,
              maxLines: 12,
              decoration: const InputDecoration(
                labelText: 'Note Content',
                hintText: 'Write down key concepts, equations, lecture points or reminders...',
                alignLabelWithHint: true,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Note content cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Big Save Button
            ElevatedButton.icon(
              onPressed: _saveNote,
              icon: const Icon(Icons.save),
              label: Text(_isEditing ? 'Update Note' : 'Save Note'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
