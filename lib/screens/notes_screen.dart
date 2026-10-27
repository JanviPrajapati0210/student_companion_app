import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import '../widgets/empty_state.dart';
import 'note_editor_screen.dart';

// Practical 6 – SQLite Notes Manager
// - Complete CRUD operations (Create, Read, Update, Delete)
// - Search filter and multiple sorting options (Newest, Oldest, Title)
// - Category filter chips
// - Swipe-to-delete using Dismissible with confirmation dialog
// - Database backup & restore and CSV export

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final DatabaseService _db = DatabaseService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List<Note> _allNotes = [];
  String _searchQuery = '';
  String _sortBy = 'date_desc'; // date_desc, date_asc, title_asc
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'General',
    'Lecture Notes',
    'Exam Prep',
    'Algorithms (CS401)',
    'Deep Learning (AI402)',
    'DBMS (CS403)',
    'Mobile Dev (SE404)',
    'Cloud Computing (EL405)',
  ];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final notes = await _db.getNotes(
      query: _searchQuery,
      category: _selectedCategory,
      sortBy: _sortBy,
    );
    if (mounted) {
      setState(() {
        _allNotes = notes;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteNote(Note note) async {
    await _db.deleteNote(note.id);
    await _loadNotes();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note "${note.title}" deleted from SQLite.'),
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.yellow,
            onPressed: () async {
              await _db.insertNote(note);
              await _loadNotes();
            },
          ),
        ),
      );
    }
  }

  Future<bool?> _confirmDelete(Note note) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to permanently delete "${note.title}" from SQLite database?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCsvExport() async {
    final csv = await _db.exportNotesToCsv();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Notes Exported to CSV'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              csv,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showBackupDialog() async {
    final jsonStr = await _db.backupDatabaseToJson();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Database Backup (JSON)'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Full validated snapshot of SQLite database tables:',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  jsonStr,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Notes (SQLite)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export Notes CSV',
            onPressed: _showCsvExport,
          ),
          IconButton(
            icon: const Icon(Icons.backup_outlined),
            tooltip: 'Database Backup',
            onPressed: _showBackupDialog,
          ),
          // Sort Options Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort Notes',
            onSelected: (val) {
              setState(() => _sortBy = val);
              _loadNotes();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'date_desc', child: Text('Date: Newest First')),
              PopupMenuItem(value: 'date_asc', child: Text('Date: Oldest First')),
              PopupMenuItem(value: 'title_asc', child: Text('Title: A to Z')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteEditorScreen()),
          );
          if (result == true) {
            _loadNotes();
          }
        },
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Field
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                      _loadNotes();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search notes by keyword, subject, category...',
                      prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                                _loadNotes();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ),

                // Category Chips
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryContainer,
                          onSelected: (val) {
                            if (val) {
                              setState(() => _selectedCategory = cat);
                              _loadNotes();
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),

                // Notes List or Responsive Grid with Dismissible
                Expanded(
                  child: _allNotes.isEmpty
                      ? EmptyStateWidget(
                          icon: Icons.note_alt_outlined,
                          title: _searchQuery.isEmpty ? 'No Notes Created Yet' : 'No Matching Notes',
                          message: _searchQuery.isEmpty
                              ? 'Tap the New Note button below to write your first study note, formula sheet, or lecture summary.'
                              : 'No notes matched "$_searchQuery". Try searching a different keyword or category.',
                          buttonText: _searchQuery.isEmpty ? 'Create First Note' : null,
                          onButtonPressed: _searchQuery.isEmpty
                              ? () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const NoteEditorScreen()),
                                  );
                                  if (result == true) _loadNotes();
                                }
                              : null,
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth > 650;
                            return RefreshIndicator(
                              onRefresh: _loadNotes,
                              child: isWide
                                  ? GridView.builder(
                                      padding: const EdgeInsets.all(16),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 14,
                                        mainAxisSpacing: 14,
                                        childAspectRatio: 1.5,
                                      ),
                                      itemCount: _allNotes.length,
                                      itemBuilder: (context, index) => _buildDismissibleNoteCard(_allNotes[index]),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      itemCount: _allNotes.length,
                                      itemBuilder: (context, index) => _buildDismissibleNoteCard(_allNotes[index]),
                                    ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  // Dismissible swipe-to-delete widget
  Widget _buildDismissibleNoteCard(Note note) {
    return Dismissible(
      key: Key('note_${note.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.errorRed,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Swipe to Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            SizedBox(width: 8),
            Icon(Icons.delete_forever, color: Colors.white),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await _confirmDelete(note);
      },
      onDismissed: (direction) async {
        await _deleteNote(note);
      },
      child: _buildNoteCard(note),
    );
  }

  Widget _buildNoteCard(Note note) {
    final dateFormatted = DateFormat('MMM d, yyyy • h:mm a').format(note.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteEditorScreen(existingNote: note),
            ),
          );
          if (result == true) {
            _loadNotes();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              note.subject,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              note.category,
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                        onPressed: () async {
                          final confirmed = await _confirmDelete(note);
                          if (confirmed == true) {
                            await _deleteNote(note);
                          }
                        },
                        tooltip: 'Delete Note',
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    note.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    note.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.35,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          dateFormatted,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                    Text(
                      '← Swipe left to delete',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
