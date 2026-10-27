import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/assignment.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import '../widgets/empty_state.dart';

// Practical 6 – SQLite Task & Assignment Manager
// - Complete CRUD: Create, Read, Update, Delete with SQLite persistence
// - Priority filter (High, Medium, Low) and Category filter (Homework, Project, etc.)
// - Search by title, subject, category, and description
// - Sorting by due date, max marks, and priority
// - Status filtering (All, Pending, Submitted, Overdue)
// - Swipe-to-delete with Dismissible and confirmation dialog
// - SQLite transactions and CSV export

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> with SingleTickerProviderStateMixin {
  final DatabaseService _db = DatabaseService();
  late TabController _tabController;

  bool _isLoading = true;
  List<Assignment> _assignments = [];
  String _searchQuery = '';
  String _selectedPriority = 'All'; // All, High, Medium, Low
  String _selectedCategory = 'All'; // All, Homework, Lab Report, Project, Quiz, Exam
  String _sortBy = 'dueDate_asc'; // dueDate_asc, dueDate_desc, marks_desc, priority_desc
  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> _courseOptions = [
    'Algorithms (CS401)',
    'Deep Learning (AI402)',
    'DBMS (CS403)',
    'Mobile Dev (SE404)',
    'Cloud Computing (EL405)',
    'General Task',
  ];

  final List<String> _categoryOptions = [
    'Homework',
    'Lab Report',
    'Project',
    'Quiz',
    'Exam',
  ];

  final List<String> _priorityOptions = [
    'High',
    'Medium',
    'Low',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _loadAssignments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAssignments() async {
    setState(() => _isLoading = true);
    final data = await _db.getAssignments(
      query: _searchQuery,
      category: _selectedCategory,
      priority: _selectedPriority,
      sortBy: _sortBy,
    );
    if (mounted) {
      setState(() {
        _assignments = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleSubmission(Assignment assignment) async {
    assignment.toggleSubmission();
    await _db.updateAssignment(assignment);
    await _loadAssignments();

    if (mounted) {
      final isNowSubmitted = assignment.isSubmitted;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isNowSubmitted
                ? 'Task "${assignment.title}" marked as Submitted!'
                : 'Task submission unmarked (Pending).',
          ),
          backgroundColor: isNowSubmitted ? AppTheme.successGreen : AppTheme.warningAmber,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Create or Edit Assignment Dialog with Form Validation
  void _showAssignmentDialog([Assignment? existing]) {
    final formKey = GlobalKey<FormState>();
    final isEditing = existing != null;

    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final marksCtrl = TextEditingController(text: (existing?.maxMarks ?? 100).toString());
    String selectedSubject = existing != null && _courseOptions.contains(existing.subject)
        ? existing.subject
        : _courseOptions.first;
    String selectedCat = existing?.category ?? 'Homework';
    String selectedPrio = existing?.priority ?? 'Medium';
    DateTime selectedDate = existing?.dueDate ?? DateTime.now().add(const Duration(days: 3));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEditing ? 'Edit Assignment / Task' : 'New Assignment / Task (SQLite)',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Title
                      TextFormField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Assignment / Task Title',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
                      ),
                      const SizedBox(height: 14),

                      // Subject Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedSubject,
                        decoration: const InputDecoration(
                          labelText: 'Subject / Course',
                          prefixIcon: Icon(Icons.menu_book),
                        ),
                        items: _courseOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedSubject = val);
                        },
                      ),
                      const SizedBox(height: 14),

                      // Category and Priority in a Row
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedCat,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                prefixIcon: Icon(Icons.folder_outlined),
                              ),
                              items: _categoryOptions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                              onChanged: (val) {
                                if (val != null) setModalState(() => selectedCat = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedPrio,
                              decoration: const InputDecoration(
                                labelText: 'Priority',
                                prefixIcon: Icon(Icons.flag_outlined),
                              ),
                              items: _priorityOptions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                              onChanged: (val) {
                                if (val != null) setModalState(() => selectedPrio = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Max Marks & Due Date Pickers
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: marksCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Max Marks',
                                prefixIcon: Icon(Icons.grade),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Enter marks';
                                if (int.tryParse(v) == null) return 'Valid number';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (picked != null) {
                                  setModalState(() => selectedDate = picked);
                                }
                              },
                              icon: const Icon(Icons.calendar_today, size: 16),
                              label: Text(
                                DateFormat('MMM d, yyyy').format(selectedDate),
                                style: const TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Description
                      TextFormField(
                        controller: descCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Instructions / Description',
                          alignLabelWithHint: true,
                          prefixIcon: Icon(Icons.description),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;

                            final maxMarks = int.tryParse(marksCtrl.text.trim()) ?? 100;

                            if (isEditing) {
                              final updated = Assignment(
                                id: existing.id,
                                title: titleCtrl.text.trim(),
                                subject: selectedSubject,
                                category: selectedCat,
                                priority: selectedPrio,
                                description: descCtrl.text.trim(),
                                dueDate: selectedDate,
                                maxMarks: maxMarks,
                                isSubmitted: existing.isSubmitted,
                                submittedAt: existing.submittedAt,
                              );
                              await _db.updateAssignment(updated);
                            } else {
                              final created = Assignment(
                                id: 'asg_${DateTime.now().millisecondsSinceEpoch}',
                                title: titleCtrl.text.trim(),
                                subject: selectedSubject,
                                category: selectedCat,
                                priority: selectedPrio,
                                description: descCtrl.text.trim(),
                                dueDate: selectedDate,
                                maxMarks: maxMarks,
                              );
                              await _db.insertAssignment(created);
                            }

                            Navigator.pop(context);
                            await _loadAssignments();

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isEditing ? 'Assignment updated in SQLite!' : 'Assignment saved in SQLite!'),
                                  backgroundColor: AppTheme.successGreen,
                                ),
                              );
                            }
                          },
                          child: Text(isEditing ? 'Update Assignment' : 'Save in SQLite Database'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Delete Assignment Confirmation Dialog
  Future<bool?> _confirmDeleteAssignment(Assignment assignment) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment?'),
        content: Text('Are you sure you want to permanently delete "${assignment.title}" from the SQLite database?'),
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

  // Demonstration of SQLite transaction batch operation
  void _runTransactionDemo() async {
    final pendingTasks = _assignments.where((a) => !a.isSubmitted).toList();
    if (pendingTasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pending tasks to update in transaction batch!')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('SQLite Transaction Demo'),
        content: Text(
          'Run an ACID atomic transaction to mark all ${pendingTasks.length} pending tasks as submitted simultaneously.\n\n'
          'If any single query fails, SQLite will automatically ROLLBACK all changes to protect database integrity.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Execute Transaction')),
        ],
      ),
    );

    if (confirmed == true) {
      final ids = pendingTasks.map((t) => t.id).toList();
      final success = await _db.batchUpdateTaskStatusInTransaction(ids, true);
      await _loadAssignments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Transaction COMMITTED! Updated ${ids.length} tasks atomically.' : 'Transaction ROLLED BACK! No changes applied.'),
            backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _showCsvExport() async {
    final csv = await _db.exportTasksToCsv();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tasks Exported to CSV'),
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

  @override
  Widget build(BuildContext context) {
    final pending = _assignments.where((a) => a.currentStatus == AssignmentStatus.pending).toList();
    final submitted = _assignments.where((a) => a.currentStatus == AssignmentStatus.submitted).toList();
    final overdue = _assignments.where((a) => a.currentStatus == AssignmentStatus.overdue).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks & SQLite DB'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export CSV',
            onPressed: _showCsvExport,
          ),
          IconButton(
            icon: const Icon(Icons.sync_alt),
            tooltip: 'Transaction Demo',
            onPressed: _runTransactionDemo,
          ),
          // Sort Options Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort Tasks',
            onSelected: (val) {
              setState(() => _sortBy = val);
              _loadAssignments();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'dueDate_asc', child: Text('Due Date: Earliest First')),
              PopupMenuItem(value: 'dueDate_desc', child: Text('Due Date: Latest First')),
              PopupMenuItem(value: 'marks_desc', child: Text('Max Marks: Highest First')),
              PopupMenuItem(value: 'priority_desc', child: Text('Priority: High to Low')),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(140),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search tasks, subjects, categories...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                              _loadAssignments();
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                  ),
                  onChanged: (val) {
                    setState(() => _searchQuery = val);
                    _loadAssignments();
                  },
                ),
              ),

              // Priority Filter Chips Row
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: ['All', 'High', 'Medium', 'Low'].map((prio) {
                    final isSel = _selectedPriority == prio;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(
                          prio == 'All' ? 'All Priorities' : '$prio Priority',
                          style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
                        ),
                        selected: isSel,
                        selectedColor: prio == 'High'
                            ? Colors.red.shade100
                            : prio == 'Medium'
                                ? Colors.amber.shade100
                                : AppTheme.primaryContainer,
                        onSelected: (val) {
                          setState(() => _selectedPriority = prio);
                          _loadAssignments();
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),

              // 4 Tabs: All, Pending, Submitted, Overdue
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryBlue,
                unselectedLabelColor: AppTheme.textMuted,
                indicatorColor: AppTheme.primaryBlue,
                indicatorWeight: 3,
                isScrollable: true,
                tabs: [
                  Tab(text: 'All (${_assignments.length})'),
                  Tab(text: 'Pending (${pending.length})'),
                  Tab(text: 'Submitted (${submitted.length})'),
                  Tab(text: 'Overdue (${overdue.length})'),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAssignmentDialog(),
        icon: const Icon(Icons.add_task),
        label: const Text('New Task'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildList(_assignments, 'No tasks match search criteria'),
                _buildList(pending, 'No pending assignments. All caught up!'),
                _buildList(submitted, 'No assignments marked as submitted yet.'),
                _buildList(overdue, 'No overdue assignments! Great job keeping up.'),
              ],
            ),
    );
  }

  Widget _buildList(List<Assignment> list, String emptyMsg) {
    if (list.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.task_alt,
        title: 'No Assignments',
        message: emptyMsg,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        return RefreshIndicator(
          onRefresh: _loadAssignments,
          child: isWide
              ? GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) => _buildDismissibleTask(list[index]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) => _buildDismissibleTask(list[index]),
                ),
        );
      },
    );
  }

  // Practical 6: Swipe-to-delete with Dismissible and confirmation dialog
  Widget _buildDismissibleTask(Assignment item) {
    return Dismissible(
      key: Key('task_${item.id}'),
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
            Text(
              'Swipe to Delete',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            SizedBox(width: 8),
            Icon(Icons.delete_forever, color: Colors.white),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await _confirmDeleteAssignment(item);
      },
      onDismissed: (direction) async {
        await _db.deleteAssignment(item.id);
        await _loadAssignments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task "${item.title}" deleted from SQLite.'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      },
      child: _buildAssignmentCard(item),
    );
  }

  Widget _buildAssignmentCard(Assignment item) {
    final status = item.currentStatus;
    final dueDateFormatted = DateFormat('MMM d, yyyy').format(item.dueDate);

    Color statusColor;
    Color statusBg;
    IconData statusIcon;

    switch (status) {
      case AssignmentStatus.submitted:
        statusColor = AppTheme.successGreen;
        statusBg = const Color(0xFFF0FDF4);
        statusIcon = Icons.check_circle_outline;
        break;
      case AssignmentStatus.overdue:
        statusColor = AppTheme.errorRed;
        statusBg = const Color(0xFFFEF2F2);
        statusIcon = Icons.error_outline;
        break;
      case AssignmentStatus.pending:
        statusColor = AppTheme.warningAmber;
        statusBg = const Color(0xFFFFFBEB);
        statusIcon = Icons.schedule;
        break;
    }

    Color prioColor;
    switch (item.priority) {
      case 'High':
        prioColor = Colors.red.shade700;
        break;
      case 'Medium':
        prioColor = Colors.amber.shade800;
        break;
      default:
        prioColor = Colors.blue.shade700;
        break;
    }

    final isOverdue = status == AssignmentStatus.overdue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isOverdue
            ? const BorderSide(color: AppTheme.errorRed, width: 1.5)
            : BorderSide(color: Colors.grey.shade200),
      ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.subject,
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
                            item.category,
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: prioColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${item.priority} Prio',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: prioColor),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: statusColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 12, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                item.statusLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Actions Menu
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 18),
                          padding: EdgeInsets.zero,
                          onSelected: (val) async {
                            if (val == 'edit') {
                              _showAssignmentDialog(item);
                            } else if (val == 'delete') {
                              final confirmed = await _confirmDeleteAssignment(item);
                              if (confirmed == true) {
                                await _db.deleteAssignment(item.id);
                                await _loadAssignments();
                              }
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text('Edit Task')])),
                            PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 16), SizedBox(width: 8), Text('Delete Task', style: TextStyle(color: Colors.red))])),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
            Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.alarm,
                      size: 14,
                      color: isOverdue ? AppTheme.errorRed : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Due: $dueDateFormatted',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isOverdue ? FontWeight.bold : FontWeight.w500,
                        color: isOverdue ? AppTheme.errorRed : Colors.grey.shade600,
                      ),
                    ),
                    if (isOverdue) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('OVERDUE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.red)),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      'Max Marks: ${item.maxMarks}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '← Swipe left to delete',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontStyle: FontStyle.italic),
                    ),
                    if (item.isSubmitted)
                      OutlinedButton.icon(
                        onPressed: () => _toggleSubmission(item),
                        icon: const Icon(Icons.undo, size: 16),
                        label: const Text('Unmark Submission', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () => _toggleSubmission(item),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Mark as Submitted', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successGreen,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
