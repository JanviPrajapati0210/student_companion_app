import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

// Dart concept demonstration:
// - Form validation, TextEditingControllers
// - Stateful modal bottom sheet or inline editing toggle
// - CopyWith pattern and local storage persistence

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StorageService _storage = StorageService();
  bool _isLoading = true;
  Student? _student;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final data = await _storage.getStudent();
    if (mounted) {
      setState(() {
        _student = data;
        _isLoading = false;
      });
    }
  }

  void _openEditProfileDialog() {
    if (_student == null) return;

    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: _student!.name);
    final deptCtrl = TextEditingController(text: _student!.department);
    final semCtrl = TextEditingController(text: _student!.semester.toString());
    final emailCtrl = TextEditingController(text: _student!.email);
    final phoneCtrl = TextEditingController(text: _student!.phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
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
                      const Text(
                        'Edit Student Profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Name
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter student name' : null,
                  ),
                  const SizedBox(height: 12),

                  // Department
                  TextFormField(
                    controller: deptCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Department / Branch',
                      prefixIcon: Icon(Icons.account_tree_outlined),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter department' : null,
                  ),
                  const SizedBox(height: 12),

                  // Semester
                  TextFormField(
                    controller: semCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Semester (1 to 8)',
                      prefixIcon: Icon(Icons.format_list_numbered),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter semester';
                      final num = int.tryParse(v);
                      if (num == null || num < 1 || num > 8) return 'Semester must be between 1 and 8';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Email
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'University Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      if (v == null || !v.contains('@') || !v.contains('.')) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Phone
                  TextFormField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Contact Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.replaceAll(RegExp(r'\D'), '').length < 10) {
                        return 'Enter at least 10 digits phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;

                      final updatedStudent = _student!.copyWith(
                        name: nameCtrl.text.trim(),
                        department: deptCtrl.text.trim(),
                        semester: int.parse(semCtrl.text.trim()),
                        email: emailCtrl.text.trim(),
                        phone: phoneCtrl.text.trim(),
                      );

                      await _storage.saveStudent(updatedStudent);
                      Navigator.pop(context);
                      _loadProfile();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile information updated successfully!'),
                          backgroundColor: AppTheme.successGreen,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Save Profile Changes'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final s = _student ?? MockDataService.getInitialStudent();

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Card with Avatar
          Card(
            elevation: 1.5,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: AppTheme.primaryContainer,
                        child: Text(
                          s.name.isNotEmpty ? s.name[0] : 'S',
                          style: const TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified, size: 16, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    s.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Enrollment: ${s.enrollmentNumber}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppConstants.universityName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _openEditProfileDialog,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit Profile Details'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Academic Information Section
          const Text(
            'Academic Information',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                _buildInfoTile(
                  icon: Icons.school_outlined,
                  label: 'Department / Major',
                  value: s.department,
                ),
                const Divider(height: 1, indent: 52),
                _buildInfoTile(
                  icon: Icons.auto_stories_outlined,
                  label: 'Current Semester',
                  value: 'Semester ${s.semester} (Undergraduate)',
                ),
                const Divider(height: 1, indent: 52),
                _buildInfoTile(
                  icon: Icons.calendar_view_day,
                  label: 'Academic Term',
                  value: AppConstants.academicTerm,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Contact Details Section
          const Text(
            'Contact & University Credentials',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                _buildInfoTile(
                  icon: Icons.mail_outline,
                  label: 'University Email',
                  value: s.email,
                ),
                const Divider(height: 1, indent: 52),
                _buildInfoTile(
                  icon: Icons.phone_outlined,
                  label: 'Phone Number',
                  value: s.phone,
                ),
          const SizedBox(height: 16),

          // Sign Out Action
          Card(
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.logout, size: 20, color: AppTheme.errorRed),
              ),
              title: const Text(
                'Log Out from Student Portal',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.errorRed),
              ),
              subtitle: const Text(
                'Sign out of your active university session',
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Log Out?'),
                    content: const Text('Are you sure you want to log out of Smart Student Companion?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
                        onPressed: () async {
                          await _storage.logout();
                          Navigator.pop(context);
                          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                        },
                        child: const Text('Log Out'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryContainer.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: AppTheme.primaryBlue),
      ),
      title: Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
      ),
    );
  }
}
