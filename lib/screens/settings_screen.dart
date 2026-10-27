import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../main.dart';

// Practical 5 – Preferences & Settings Screen
// - SharedPreferences persistence for Theme (Light/Dark), Semester, and Notification Alerts
// - Immediate restore when restarting the app

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onThemeChanged;

  const SettingsScreen({super.key, this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storage = StorageService();

  bool _isLoading = true;
  bool _isDarkMode = false;
  int _selectedSemester = 4;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final isDark = await _storage.getThemeMode() == 'dark';
    final sem = await _storage.getPreferredSemester();
    final notifs = await _storage.getNotificationsEnabled();

    if (mounted) {
      setState(() {
        _isDarkMode = isDark;
        _selectedSemester = sem;
        _notificationsEnabled = notifs;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleTheme(bool isDark) async {
    setState(() => _isDarkMode = isDark);
    await ThemeController.toggleTheme(isDark);
    widget.onThemeChanged?.call();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Theme set to ${isDark ? "Dark Mode" : "Light Mode"} (saved in SharedPreferences)'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _changeSemester(int sem) async {
    setState(() => _selectedSemester = sem);
    await _storage.setPreferredSemester(sem);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Default Academic Semester updated to Semester $sem'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _toggleNotifications(bool enabled) async {
    setState(() => _notificationsEnabled = enabled);
    await _storage.setNotificationsEnabled(enabled);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Push notifications & alerts ${enabled ? "Enabled" : "Muted"}'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Preferences & Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Section
          const Text(
            'Appearance & Theming (Practical 5)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isDarkMode ? Colors.indigo.withOpacity(0.2) : Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                      color: _isDarkMode ? Colors.indigoAccent : Colors.amber.shade800,
                    ),
                  ),
                  title: const Text('Dark Theme Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(
                    _isDarkMode ? 'Material 3 Slate Dark Mode enabled' : 'Clean Academic Blue Light Mode',
                    style: const TextStyle(fontSize: 11),
                  ),
                  value: _isDarkMode,
                  activeColor: AppTheme.primaryLight,
                  onChanged: _toggleTheme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Academic Settings Section
          const Text(
            'Academic Configuration',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Active Academic Semester',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      DropdownButton<int>(
                        value: _selectedSemester,
                        items: List.generate(8, (i) => i + 1).map((s) {
                          return DropdownMenuItem(value: s, child: Text('Semester $s'));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) _changeSemester(val);
                        },
                      ),
                    ],
                  ),
                  const Text(
                    'Stored in SharedPreferences and preserved across app restarts.',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Notification Settings
          const Text(
            'Notification Alerts',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.notifications_active_outlined, color: AppTheme.primaryBlue),
              ),
              title: const Text('Attendance Shortage Alerts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Receive warnings when course attendance drops below 75%', style: TextStyle(fontSize: 11)),
              value: _notificationsEnabled,
              activeColor: AppTheme.primaryBlue,
              onChanged: _toggleNotifications,
            ),
          ),
          const SizedBox(height: 16),

          // Storage & Practical Info
          const Text(
            'System Architecture Info',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.storage_outlined, size: 16, color: AppTheme.primaryLight),
                      SizedBox(width: 8),
                      Text('Dual Persistence Engines Active:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('1. SQLite (sqflite): Notes & Task Manager records with CRUD operations (Practical 6).', style: TextStyle(fontSize: 11)),
                  const SizedBox(height: 4),
                  const Text('2. SharedPreferences: Theme mode, preferred semester, session login & settings (Practical 5).', style: TextStyle(fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
