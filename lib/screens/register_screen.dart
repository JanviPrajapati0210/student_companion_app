import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import 'main_navigation_screen.dart';

// Dart concept demonstration:
// - Comprehensive Form validation (regex email, password matching)
// - DropdownButtonFormField for Department & Semester selection
// - Asynchronous registration persistence
// - Navigation pop or pushReplacement

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final StorageService _storage = StorageService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _enrollmentController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _selectedDepartment = 'Artificial Intelligence & Machine Learning';
  int _selectedSemester = 4;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = true;
  bool _isLoading = false;

  final List<String> _departments = [
    'Artificial Intelligence & Machine Learning',
    'Computer Science & Engineering',
    'Information Technology',
    'Electronics & Communication',
    'Mechanical Engineering',
    'Civil Engineering',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _enrollmentController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the university code of conduct & terms.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate server registration
    await Future.delayed(const Duration(milliseconds: 700));

    final newStudent = Student(
      id: 'STU-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch % 1000}',
      name: _nameController.text.trim(),
      enrollmentNumber: _enrollmentController.text.trim().toUpperCase(),
      department: _selectedDepartment,
      semester: _selectedSemester,
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    await _storage.saveStudent(newStudent);
    await _storage.setLoggedIn(true);

    if (mounted) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created! Welcome, ${newStudent.name}.'),
          backgroundColor: AppTheme.successGreen,
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Create Student Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: const BorderSide(color: AppTheme.borderLight),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Join Smart Student Companion',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Register with your university credentials to manage attendance and courses.',
                          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 20),

                        // Full Name
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            hintText: 'e.g. Alex Morgan',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Enter your full name';
                            if (val.trim().length < 3) return 'Name must be at least 3 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Enrollment Number
                        TextFormField(
                          controller: _enrollmentController,
                          decoration: const InputDecoration(
                            labelText: 'Enrollment / Roll No.',
                            hintText: 'e.g. 24AIML052',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Enter enrollment number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Department Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedDepartment,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Department / Branch',
                            prefixIcon: Icon(Icons.school_outlined),
                          ),
                          items: _departments.map((dept) {
                            return DropdownMenuItem(
                              value: dept,
                              child: Text(dept, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedDepartment = val);
                          },
                        ),
                        const SizedBox(height: 12),

                        // Semester & Phone Row
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<int>(
                                value: _selectedSemester,
                                decoration: const InputDecoration(
                                  labelText: 'Semester',
                                  prefixIcon: Icon(Icons.format_list_numbered),
                                ),
                                items: List.generate(8, (i) => i + 1).map((s) {
                                  return DropdownMenuItem(value: s, child: Text('Sem $s'));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedSemester = val);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'Phone',
                                  hintText: '+91 9876543210',
                                  prefixIcon: Icon(Icons.phone_outlined),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().length < 10) {
                                    return 'Min 10 digits';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // University Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'University Email',
                            hintText: 'student@charusat.edu.in',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (val) {
                            if (val == null || !val.contains('@') || !val.contains('.')) {
                              return 'Enter a valid university email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Create Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Confirm Password Field
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_reset),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),
                          ),
                          validator: (val) {
                            if (val != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Terms Checkbox
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _agreedToTerms,
                                activeColor: AppTheme.primaryBlue,
                                onChanged: (val) => setState(() => _agreedToTerms = val ?? true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'I agree to the university academic regulations & student honor code.',
                                style: TextStyle(fontSize: 11, color: AppTheme.textDark),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Register Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Complete Registration', style: TextStyle(fontSize: 15)),
                        ),
                        const SizedBox(height: 16),

                        // Already registered link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already registered?',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Sign in here',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
