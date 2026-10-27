import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';
import '../models/assignment.dart';
import 'mock_data_service.dart';

// ============================================================================
// Practical 6: SQLite Database Service & Helper using sqflite and path
// ============================================================================
// Features implemented:
// 1. Singleton pattern with private constructor and static factory
// 2. Database initialization, versioning, table creation, and onUpgrade migrations
// 3. Complete CRUD operations for Notes and Tasks
// 4. Advanced search, sorting, category, and priority filtering
// 5. ACID transactions: db.transaction() for atomic batch operations with automatic rollback
// 6. Database Backup & Restore with JSON validation and confirmation
// 7. CSV and formatted report export helpers
// ============================================================================

class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  static Database? _database;
  static const int _dbVersion = 2;
  static const String _dbName = 'student_companion.db';

  // In-memory web fallback cache so it runs smoothly across both Android & Web
  final List<Note> _memNotes = [];
  final List<Assignment> _memAssignments = [];
  bool _initialized = false;

  Future<Database?> get database async {
    if (kIsWeb) return null; // Web platforms use fallback memory cache
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Notes Table
    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subject TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT 'General',
        description TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        colorValue INTEGER NOT NULL
      )
    ''');

    // 2. Tasks / Assignments Table with priority and category
    await db.execute('''
      CREATE TABLE assignments (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subject TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT 'Homework',
        priority TEXT NOT NULL DEFAULT 'Medium',
        description TEXT NOT NULL,
        dueDate TEXT NOT NULL,
        maxMarks INTEGER NOT NULL,
        isSubmitted INTEGER NOT NULL,
        submittedAt TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Schema upgrade migration: add priority and category columns
      try {
        await db.execute("ALTER TABLE notes ADD COLUMN category TEXT NOT NULL DEFAULT 'General'");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE assignments ADD COLUMN category TEXT NOT NULL DEFAULT 'Homework'");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE assignments ADD COLUMN priority TEXT NOT NULL DEFAULT 'Medium'");
      } catch (_) {}
    }
  }

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    if (kIsWeb) {
      if (_memNotes.isEmpty) {
        _memNotes.addAll(MockDataService.getInitialNotes());
      }
      if (_memAssignments.isEmpty) {
        _memAssignments.addAll(MockDataService.getInitialAssignments());
      }
      return;
    }

    try {
      final db = await database;
      if (db != null) {
        final noteCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM notes')) ?? 0;
        if (noteCount == 0) {
          final initNotes = MockDataService.getInitialNotes();
          for (var n in initNotes) {
            await insertNote(n);
          }
        }

        final asgCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM assignments')) ?? 0;
        if (asgCount == 0) {
          final initAsg = MockDataService.getInitialAssignments();
          for (var a in initAsg) {
            await insertAssignment(a);
          }
        }
      }
    } catch (e) {
      debugPrint('Database initialization warning: $e');
    }
  }

  // =========================================================================
  // NOTES CRUD OPERATIONS (Practical 6)
  // =========================================================================

  Future<List<Note>> getNotes({
    String query = '',
    String category = 'All',
    String sortBy = 'date_desc',
  }) async {
    await init();
    if (kIsWeb) {
      var filtered = List<Note>.from(_memNotes);
      if (query.trim().isNotEmpty) {
        final q = query.toLowerCase();
        filtered = filtered.where((n) =>
          n.title.toLowerCase().contains(q) ||
          n.subject.toLowerCase().contains(q) ||
          n.category.toLowerCase().contains(q) ||
          n.description.toLowerCase().contains(q)
        ).toList();
      }
      if (category != 'All') {
        filtered = filtered.where((n) =>
          n.subject.toLowerCase() == category.toLowerCase() ||
          n.category.toLowerCase() == category.toLowerCase()
        ).toList();
      }
      if (sortBy == 'date_desc') {
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else if (sortBy == 'date_asc') {
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      } else if (sortBy == 'title_asc') {
        filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      }
      return filtered;
    }

    final db = await database;
    if (db == null) return _memNotes;

    String orderBy = 'createdAt DESC';
    if (sortBy == 'date_asc') orderBy = 'createdAt ASC';
    if (sortBy == 'title_asc') orderBy = 'title ASC';

    List<Map<String, dynamic>> maps;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (query.trim().isNotEmpty) {
      whereClauses.add('(title LIKE ? OR subject LIKE ? OR category LIKE ? OR description LIKE ?)');
      whereArgs.addAll(['%$query%', '%$query%', '%$query%', '%$query%']);
    }

    if (category != 'All') {
      whereClauses.add('(subject = ? OR category = ?)');
      whereArgs.addAll([category, category]);
    }

    final whereString = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    maps = await db.query(
      'notes',
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: orderBy,
    );

    return maps.map((m) => Note.fromMap(m)).toList();
  }

  Future<int> insertNote(Note note) async {
    await init();
    if (kIsWeb) {
      _memNotes.insert(0, note);
      return 1;
    }
    final db = await database;
    if (db == null) {
      _memNotes.insert(0, note);
      return 1;
    }
    return await db.insert('notes', note.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateNote(Note note) async {
    await init();
    if (kIsWeb) {
      final index = _memNotes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _memNotes[index] = note;
        return 1;
      }
      return 0;
    }
    final db = await database;
    if (db == null) return 0;
    return await db.update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  Future<int> deleteNote(String id) async {
    await init();
    if (kIsWeb) {
      _memNotes.removeWhere((n) => n.id == id);
      return 1;
    }
    final db = await database;
    if (db == null) return 0;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // =========================================================================
  // ASSIGNMENTS / TASKS CRUD OPERATIONS (Practical 6)
  // =========================================================================

  Future<List<Assignment>> getAssignments({
    String query = '',
    String category = 'All',
    String priority = 'All',
    String statusFilter = 'all',
    String sortBy = 'dueDate_asc',
  }) async {
    await init();
    if (kIsWeb) {
      var list = List<Assignment>.from(_memAssignments);
      if (query.trim().isNotEmpty) {
        final q = query.toLowerCase();
        list = list.where((a) =>
          a.title.toLowerCase().contains(q) ||
          a.subject.toLowerCase().contains(q) ||
          a.category.toLowerCase().contains(q) ||
          a.description.toLowerCase().contains(q)
        ).toList();
      }
      if (category != 'All') {
        list = list.where((a) => a.category.toLowerCase() == category.toLowerCase()).toList();
      }
      if (priority != 'All') {
        list = list.where((a) => a.priority.toLowerCase() == priority.toLowerCase()).toList();
      }
      if (statusFilter == 'pending') {
        list = list.where((a) => a.currentStatus == AssignmentStatus.pending).toList();
      } else if (statusFilter == 'submitted') {
        list = list.where((a) => a.currentStatus == AssignmentStatus.submitted).toList();
      } else if (statusFilter == 'overdue') {
        list = list.where((a) => a.currentStatus == AssignmentStatus.overdue).toList();
      }

      if (sortBy == 'dueDate_asc') {
        list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      } else if (sortBy == 'dueDate_desc') {
        list.sort((a, b) => b.dueDate.compareTo(a.dueDate));
      } else if (sortBy == 'marks_desc') {
        list.sort((a, b) => b.maxMarks.compareTo(a.maxMarks));
      } else if (sortBy == 'priority_desc') {
        final rank = {'High': 3, 'Medium': 2, 'Low': 1};
        list.sort((a, b) => (rank[b.priority] ?? 0).compareTo(rank[a.priority] ?? 0));
      }
      return list;
    }

    final db = await database;
    if (db == null) return _memAssignments;

    String orderBy = 'dueDate ASC';
    if (sortBy == 'dueDate_desc') orderBy = 'dueDate DESC';
    if (sortBy == 'marks_desc') orderBy = 'maxMarks DESC';

    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (query.trim().isNotEmpty) {
      whereClauses.add('(title LIKE ? OR subject LIKE ? OR category LIKE ? OR description LIKE ?)');
      whereArgs.addAll(['%$query%', '%$query%', '%$query%', '%$query%']);
    }

    if (category != 'All') {
      whereClauses.add('category = ?');
      whereArgs.add(category);
    }

    if (priority != 'All') {
      whereClauses.add('priority = ?');
      whereArgs.add(priority);
    }

    final whereString = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final maps = await db.query(
      'assignments',
      where: whereString,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: orderBy,
    );

    var list = maps.map((m) => Assignment.fromMap(m)).toList();
    if (statusFilter == 'pending') {
      list = list.where((a) => a.currentStatus == AssignmentStatus.pending).toList();
    } else if (statusFilter == 'submitted') {
      list = list.where((a) => a.currentStatus == AssignmentStatus.submitted).toList();
    } else if (statusFilter == 'overdue') {
      list = list.where((a) => a.currentStatus == AssignmentStatus.overdue).toList();
    }
    return list;
  }

  Future<int> insertAssignment(Assignment asg) async {
    await init();
    if (kIsWeb) {
      _memAssignments.add(asg);
      return 1;
    }
    final db = await database;
    if (db == null) {
      _memAssignments.add(asg);
      return 1;
    }
    return await db.insert('assignments', asg.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateAssignment(Assignment asg) async {
    await init();
    if (kIsWeb) {
      final index = _memAssignments.indexWhere((a) => a.id == asg.id);
      if (index != -1) {
        _memAssignments[index] = asg;
        return 1;
      }
      return 0;
    }
    final db = await database;
    if (db == null) return 0;
    return await db.update('assignments', asg.toMap(), where: 'id = ?', whereArgs: [asg.id]);
  }

  Future<int> deleteAssignment(String id) async {
    await init();
    if (kIsWeb) {
      _memAssignments.removeWhere((a) => a.id == id);
      return 1;
    }
    final db = await database;
    if (db == null) return 0;
    return await db.delete('assignments', where: 'id = ?', whereArgs: [id]);
  }

  // =========================================================================
  // ADVANCED: SQLITE TRANSACTIONS (Practical 6)
  // Atomic batch operations with automatic rollback on error
  // =========================================================================

  Future<bool> batchUpdateTaskStatusInTransaction(List<String> taskIds, bool isSubmitted) async {
    await init();
    final nowIso = DateTime.now().toIso8601String();

    if (kIsWeb) {
      // In-memory atomic update
      for (final id in taskIds) {
        final idx = _memAssignments.indexWhere((a) => a.id == id);
        if (idx != -1) {
          _memAssignments[idx].isSubmitted = isSubmitted;
          _memAssignments[idx].submittedAt = isSubmitted ? DateTime.now() : null;
        }
      }
      return true;
    }

    final db = await database;
    if (db == null) return false;

    try {
      await db.transaction((txn) async {
        for (final id in taskIds) {
          await txn.update(
            'assignments',
            {
              'isSubmitted': isSubmitted ? 1 : 0,
              'submittedAt': isSubmitted ? nowIso : null,
            },
            where: 'id = ?',
            whereArgs: [id],
          );
        }
      });
      return true;
    } catch (e) {
      debugPrint('Transaction failed and rolled back: $e');
      return false;
    }
  }

  Future<bool> batchImportInTransaction({required List<Note> notes, required List<Assignment> tasks}) async {
    await init();
    if (kIsWeb) {
      _memNotes.addAll(notes);
      _memAssignments.addAll(tasks);
      return true;
    }

    final db = await database;
    if (db == null) return false;

    try {
      await db.transaction((txn) async {
        for (final note in notes) {
          await txn.insert('notes', note.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
        }
        for (final task in tasks) {
          await txn.insert('assignments', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
        }
      });
      return true;
    } catch (e) {
      debugPrint('Batch import transaction failed and rolled back: $e');
      return false;
    }
  }

  // =========================================================================
  // ADVANCED: DATABASE BACKUP & RESTORE WITH VALIDATION (Practical 6)
  // =========================================================================

  Future<String> backupDatabaseToJson() async {
    final allNotes = await getNotes();
    final allTasks = await getAssignments();

    final backupPayload = {
      'app': 'Smart Student Companion',
      'version': _dbVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'notesCount': allNotes.length,
      'tasksCount': allTasks.length,
      'notes': allNotes.map((n) => n.toMap()).toList(),
      'assignments': allTasks.map((t) => t.toMap()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(backupPayload);
  }

  Future<bool> restoreDatabaseFromJson(String jsonString) async {
    await init();
    try {
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid JSON root object');
      }

      // Schema validation
      if (!decoded.containsKey('notes') || !decoded.containsKey('assignments')) {
        throw const FormatException('Backup JSON missing required "notes" or "assignments" keys');
      }

      final notesListRaw = decoded['notes'] as List<dynamic>;
      final tasksListRaw = decoded['assignments'] as List<dynamic>;

      final List<Note> parsedNotes = [];
      for (final item in notesListRaw) {
        if (item is Map<String, dynamic>) {
          parsedNotes.add(Note.fromMap(item));
        }
      }

      final List<Assignment> parsedTasks = [];
      for (final item in tasksListRaw) {
        if (item is Map<String, dynamic>) {
          parsedTasks.add(Assignment.fromMap(item));
        }
      }

      if (kIsWeb) {
        _memNotes.clear();
        _memNotes.addAll(parsedNotes);
        _memAssignments.clear();
        _memAssignments.addAll(parsedTasks);
        return true;
      }

      final db = await database;
      if (db == null) return false;

      // Atomic restore inside transaction: clear old tables and insert validated items
      await db.transaction((txn) async {
        await txn.delete('notes');
        await txn.delete('assignments');

        for (final note in parsedNotes) {
          await txn.insert('notes', note.toMap());
        }
        for (final task in parsedTasks) {
          await txn.insert('assignments', task.toMap());
        }
      });

      return true;
    } catch (e) {
      debugPrint('Restore failed: $e');
      return false;
    }
  }

  // =========================================================================
  // ADVANCED: CSV & REPORT EXPORT (Practical 6)
  // =========================================================================

  Future<String> exportNotesToCsv() async {
    final notes = await getNotes();
    final buffer = StringBuffer();
    buffer.writeln('ID,Title,Subject,Category,Created_At,Description');
    for (final n in notes) {
      final safeTitle = n.title.replaceAll('"', '""');
      final safeDesc = n.description.replaceAll('"', '""').replaceAll('\n', ' ');
      buffer.writeln('"${n.id}","${safeTitle}","${n.subject}","${n.category}","${n.createdAt.toIso8601String()}","${safeDesc}"');
    }
    return buffer.toString();
  }

  Future<String> exportTasksToCsv() async {
    final tasks = await getAssignments();
    final buffer = StringBuffer();
    buffer.writeln('ID,Title,Subject,Category,Priority,Due_Date,Max_Marks,Status');
    for (final t in tasks) {
      final safeTitle = t.title.replaceAll('"', '""');
      buffer.writeln('"${t.id}","${safeTitle}","${t.subject}","${t.category}","${t.priority}","${t.dueDate.toIso8601String()}",${t.maxMarks},"${t.statusLabel}"');
    }
    return buffer.toString();
  }
}
