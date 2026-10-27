import 'package:flutter/material.dart';

// Dart concept demonstration:
// - Conditional color logic based on threshold
// - Visual indicators (LinearProgressIndicator & CircularProgressIndicator)
// - Reusable UI component

class AttendanceProgressBar extends StatelessWidget {
  final double percentage;
  final double height;
  final bool showLabel;

  const AttendanceProgressBar({
    super.key,
    required this.percentage,
    this.height = 8.0,
    this.showLabel = true,
  });

  Color get progressColor {
    if (percentage >= 85) return const Color(0xFF16A34A); // High: Green
    if (percentage >= 75) return const Color(0xFF0284C7); // Safe: Blue
    if (percentage >= 65) return const Color(0xFFD97706); // Warning: Amber
    return const Color(0xFFDC2626); // Critical: Red
  }

  @override
  Widget build(BuildContext context) {
    final clampedFraction = (percentage / 100.0).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: clampedFraction,
            minHeight: height,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attendance: ${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: progressColor,
                ),
              ),
              Text(
                percentage >= 75.0 ? 'Requirement met' : 'Shortage warning (<75%)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: percentage >= 75.0 ? Colors.grey.shade600 : const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
