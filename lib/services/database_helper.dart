import 'dart:async';
import 'database_service.dart';
import '../models/note.dart';
import '../models/assignment.dart';

// ============================================================================
// Practical 6: DatabaseHelper (Standard University Pattern)
// Singleton wrapper matching standard academic curriculum naming
// ============================================================================

class DatabaseHelper {
  // Private constructor
  DatabaseHelper._internal();

  // Static Singleton instance
  static final DatabaseHelper instance = DatabaseHelper._internal();

  // Factory constructor
  factory DatabaseHelper() => instance;

  final DatabaseService _service = DatabaseService();

  // Initialization
  Future<void> initDatabase() async {
    await _service.init();
  }

  // Notes CRUD
  Future<List<Note>> getAllNotes({String query = '', String category = 'All', String sortBy = 'date_desc'}) =>
      _service.getNotes(query: query, category: category, sortBy: sortBy);

  Future<int> insertNote(Note note) => _service.insertNote(note);
  Future<int> updateNote(Note note) => _service.updateNote(note);
  Future<int> deleteNote(String id) => _service.deleteNote(id);

  // Tasks CRUD
  Future<List<Assignment>> getAllTasks({
    String query = '',
    String category = 'All',
    String priority = 'All',
    String statusFilter = 'all',
    String sortBy = 'dueDate_asc',
  }) => _service.getAssignments(
        query: query,
        category: category,
        priority: priority,
        statusFilter: statusFilter,
        sortBy: sortBy,
      );

  Future<int> insertTask(Assignment task) => _service.insertAssignment(task);
  Future<int> updateTask(Assignment task) => _service.updateAssignment(task);
  Future<int> deleteTask(String id) => _service.deleteAssignment(id);

  // Multi-step transaction with rollback
  Future<bool> batchUpdateTaskStatus(List<String> taskIds, bool isSubmitted) =>
      _service.batchUpdateTaskStatusInTransaction(taskIds, isSubmitted);

  // Backup & Restore
  Future<String> backupToJson() => _service.backupDatabaseToJson();
  Future<bool> restoreFromJson(String json) => _service.restoreDatabaseFromJson(json);

  // Export
  Future<String> exportNotesCsv() => _service.exportNotesToCsv();
  Future<String> exportTasksCsv() => _service.exportTasksToCsv();
}
