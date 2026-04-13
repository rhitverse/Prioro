import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prioro/colors.dart';

class TaskOverviewCards extends StatelessWidget {
  final String title;
  final String? startDateLabel;
  final String dueDateLabel;
  final DateTime? dueDateTime;
  final String priorityLabel;
  final String? statusLabel;
  final int totalSubtasks;
  final int completedSubtasks;
  final int? progressPercent;

  const TaskOverviewCards({
    super.key,
    required this.title,
    this.startDateLabel,
    required this.dueDateLabel,
    this.dueDateTime,
    required this.priorityLabel,
    this.statusLabel,
    required this.totalSubtasks,
    required this.completedSubtasks,
    this.progressPercent,
  });

  String _buildDuringLabel() {
    if (dueDateTime == null) return 'During --';

    final now = DateTime.now();
    final difference = dueDateTime!.difference(now);

    if (difference.isNegative) return 'During ended';

    if (difference.inHours < 24) {
      final hoursLeft = difference.inHours <= 0 ? 1 : difference.inHours;
      return 'During ${hoursLeft}h left';
    }

    if (difference.inDays < 7) {
      final daysLeft = difference.inDays <= 0 ? 1 : difference.inDays;
      return 'During ${daysLeft}d left';
    }

    final weeksLeft = (difference.inDays / 7).ceil();
    return 'During ${weeksLeft}w left';
  }

  @override
  Widget build(BuildContext context) {
    final fallbackPercent = totalSubtasks == 0
        ? 0
        : ((completedSubtasks / totalSubtasks) * 100).round();
    final completionPercent = (progressPercent ?? fallbackPercent).clamp(
      0,
      100,
    );
    final completionProgress = completionPercent / 100;
    final effectiveStatusLabel =
        statusLabel ?? (completionPercent >= 100 ? 'Completed' : 'In Progress');
    final duringLabel = _buildDuringLabel();
    final orangeShadow = const Color(0xFFF39A2F).withOpacity(0.18);
    final cardShadow = Colors.black.withOpacity(0.08);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [const Color(0xFFE1AC63), appbarColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: orangeShadow,
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 26,
                  height: 1.05,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  _MetaPill(color: Colors.red, text: priorityLabel),
                  _MetaPill(
                    color: Colors.brown,
                    text: duringLabel,
                    leadingIcon: Icons.schedule,
                  ),
                  _MetaPill(
                    color: Colors.blue,
                    text: effectiveStatusLabel,
                    showLoader:
                        effectiveStatusLabel.toLowerCase() == 'in progress',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: cardShadow,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _DateMetric(
                      label: 'Start Date',
                      value: startDateLabel ?? 'No date',
                      iconAsset: 'assets/svg/orangeCalendar.svg',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateMetric(
                      label: 'Due Date',
                      value: dueDateLabel,
                      iconAsset: 'assets/svg/redCalendar.svg',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress $completionPercent%',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: completionProgress,
                  minHeight: 7,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFF6A1F),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetaPill extends StatelessWidget {
  final Color color;
  final String text;
  final IconData? leadingIcon;
  final bool showLoader;

  const _MetaPill({
    required this.color,
    required this.text,
    this.leadingIcon,
    this.showLoader = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        showLoader
            ? SizedBox(
                width: 11,
                height: 11,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            : leadingIcon != null
            ? Icon(leadingIcon, size: 13, color: Colors.black87)
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DateMetric extends StatelessWidget {
  final String label;
  final String value;
  final String iconAsset;

  const _DateMetric({
    required this.label,
    required this.value,
    required this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SvgPicture.asset(iconAsset, width: 42, height: 42),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
