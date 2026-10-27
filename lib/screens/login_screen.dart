import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import 'register_screen.dart';
import 'main_navigation_screen.dart';

// Dart concept demonstration:
// - StatefulWidget for dynamic form state management
// - GlobalKey<FormState> for validation logic
// - ObscureText toggle with stateful boolean (_obscurePassword)
// - Asynchronous authentication logic (async/await)

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final StorageService _storage = StorageService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Pre-fill demo student credentials for viva practical testing
  void _fillDemoCredentials() {
    setState(() {
      _emailController.text = 'alex.morgan@charusat.edu.in';
      _passwordController.text = 'student123';
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Simulate network authentication delay
    await Future.delayed(const Duration(milliseconds: 700));

    final success = await _storage.authenticateStudent(email, password);

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful! Welcome back.'),
            backgroundColor: AppTheme.successGreen,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials. Please verify your email & password.'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailCtrl = TextEditingController(text: _emailController.text);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset University Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your registered university email. A password recovery link will be sent to your student portal.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: resetEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'University Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password reset instructions sent to university email!'),
                  backgroundColor: AppTheme.primaryBlue,
                ),
              );
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
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
                        // App Logo & Header
                        Center(
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.primaryBlue, AppTheme.primaryLight],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              size: 38,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          AppConstants.appName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),

                        const Text(
                          'Sign in to access your student portal, courses, and attendance',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Quick Demo Login Button for Viva / Testing
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'College Demo Student',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E40AF),
                                    ),
                                  ),
                                  Text(
                                    'alex.morgan@charusat.edu.in',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF3B82F6)),
                                  ),
                                ],
                              ),
                              TextButton.icon(
                                onPressed: _fillDemoCredentials,
                                icon: const Icon(Icons.flash_on, size: 14),
                                label: const Text('Auto-Fill', style: TextStyle(fontSize: 11)),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'University Email',
                            hintText: 'student@charusat.edu.in',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!val.contains('@') || !val.contains('.')) {
                              return 'Enter a valid university email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Password Field with Eye Toggle
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (val.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        // Remember Me & Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    activeColor: AppTheme.primaryBlue,
                                    onChanged: (val) {
                                      setState(() => _rememberMe = val ?? true);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Remember me',
                                  style: TextStyle(fontSize: 12, color: AppTheme.textDark),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: _showForgotPasswordDialog,
                              child: const Text(
                                'Forgot password?',
                                style: TextStyle(fontSize: 12, color: AppTheme.primaryLight),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Submit Button
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.login, size: 18),
                                    SizedBox(width: 8),
                                    Text('Sign In', style: TextStyle(fontSize: 15)),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 20),

                        // Register Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Don\'t have an account?',
                              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                );
                              },
                              child: const Text(
                                'Register Now',
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
