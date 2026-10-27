import 'package:flutter/material.dart';
import '../models/attendance_record.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/attendance_indicator.dart';

// Dart concept demonstration:
// - StatefulWidget with setState() to dynamically recompute percentages
// - Loops, arithmetic operations, and conditional warnings (< 75%)
// - Dialog interactions to record new class attendance

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final StorageService _storage = StorageService();
  bool _isLoading = true;
  List<AttendanceRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() => _isLoading = true);
    final data = await _storage.getAttendance();
    if (mounted) {
      setState(() {
        _records = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateAttendance(String courseCode, bool wasPresent) async {
    await _storage.markAttendance(courseCode, wasPresent);
    final updated = await _storage.getAttendance();
    if (mounted) {
      setState(() {
        _records = updated;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasPresent ? 'Marked Present (+1 attended class)' : 'Marked Absent (+1 missed class)',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: wasPresent ? AppTheme.successGreen : AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Calculate aggregated attendance statistics using for loop
    int totalOverallClasses = 0;
    int totalAttendedClasses = 0;
    int subjectsWithShortage = 0;

    for (var r in _records) {
      totalOverallClasses += r.totalClasses;
      totalAttendedClasses += r.attendedClasses;
      if (r.isShortage) {
        subjectsWithShortage++;
      }
    }

    final double overallPercent = totalOverallClasses == 0
        ? 100.0
        : (totalAttendedClasses / totalOverallClasses) * 100.0;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadAttendance,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Overall Attendance Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Aggregate Attendance',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${overallPercent.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: overallPercent >= 75
                                  ? AppTheme.primaryBlue
                                  : AppTheme.errorRed,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: subjectsWithShortage > 0
                              ? const Color(0xFFFEF2F2)
                              : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: subjectsWithShortage > 0
                                ? const Color(0xFFFCA5A5)
                                : const Color(0xFFBBF7D0),
                          ),
                        ),
                        child: Text(
                          subjectsWithShortage > 0
                              ? '$subjectsWithShortage Subject Alert'
                              : 'All Clear',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: subjectsWithShortage > 0
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF16A34A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AttendanceProgressBar(percentage: overallPercent, height: 10, showLabel: false),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat('Total Held', '$totalOverallClasses', Colors.grey.shade800),
                      Container(height: 24, width: 1, color: Colors.grey.shade200),
                      _buildMiniStat('Attended', '$totalAttendedClasses', AppTheme.successGreen),
                      Container(height: 24, width: 1, color: Colors.grey.shade200),
                      _buildMiniStat(
                        'Missed',
                        '${totalOverallClasses - totalAttendedClasses}',
                        AppTheme.errorRed,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Enrolled Subject Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 10),

            // Subject Cards
            ..._records.map((record) {
              final isUnder75 = record.isShortage;
              final neededClasses = record.classesNeededForTarget(75.0);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isUnder75 ? const Color(0xFFFCA5A5) : Colors.grey.shade200,
                    width: isUnder75 ? 1.5 : 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    record.courseCode,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    record.courseName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            record.formattedPercentage,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isUnder75 ? AppTheme.errorRed : AppTheme.successGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      AttendanceProgressBar(
                        percentage: record.percentage,
                        height: 7,
                        showLabel: true,
                      ),

                      const SizedBox(height: 12),

                      // Stat row: Attended, Missed, Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Attended: ${record.attendedClasses}/${record.totalClasses}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                          Text(
                            'Missed: ${record.missedClasses}',
                            style: TextStyle(
                              fontSize: 12,
                              color: record.missedClasses > 5 ? AppTheme.errorRed : AppTheme.textMuted,
                              fontWeight: record.missedClasses > 5 ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),

                      if (isUnder75) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, size: 16, color: Color(0xFFDC2626)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Attend next $neededClasses consecutive classes to reach 75%.',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF991B1B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 10),

                      // Quick attendance updater actions
                      Wrap(
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          const Text(
                            'Update record:',
                            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _updateAttendance(record.courseCode, false),
                            icon: const Icon(Icons.close, size: 14, color: AppTheme.errorRed),
                            label: const Text('Absent', style: TextStyle(fontSize: 11, color: AppTheme.errorRed)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              visualDensity: VisualDensity.compact,
                              side: BorderSide(color: Colors.red.shade200),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _updateAttendance(record.courseCode, true),
                            icon: const Icon(Icons.check, size: 14, color: Colors.white),
                            label: const Text('Present', style: TextStyle(fontSize: 11)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.successGreen,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
        ),
      ],
    );
  }
}
