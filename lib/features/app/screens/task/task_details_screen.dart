import 'dart:async';

import 'package:flutter/material.dart';
import 'package:prioro/features/app/screens/task/controller/task_controller.dart';
import 'package:prioro/features/app/screens/task/widget/task_description_card.dart';
import 'package:prioro/features/app/screens/task/widget/task_details_bottom_bar.dart';
import 'package:prioro/features/app/screens/task/widget/task_overview_cards.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final TaskController _taskController = TaskController();

  String _formatDate(String? value) {
    if (value == null || value.isEmpty) return 'No date';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    return '${parsed.year}-$month-$day';
  }

  String _getPriorityLabel(Map<String, dynamic> task) {
    final priority = task['priority']?.toString().toLowerCase();
    switch (priority) {
      case 'high':
        return 'High Priority';
      case 'medium':
        return 'Medium Priority';
      case 'low':
        return 'Low Priority';
      default:
        return 'Medium';
    }
  }

  String _formatDueDate(String? value) {
    if (value == null || value.isEmpty) return 'No due date';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    return '$day-$month-${parsed.year}';
  }

  void _showDeleteConfirmation() {
    final parentContext = context;
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final taskId = widget.task['id']?.toString() ?? '';
              Navigator.pop(dialogContext);

              if (taskId.isEmpty) {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(
                    content: Text('Task id missing, cannot delete'),
                  ),
                );
                return;
              }

              Navigator.pop(parentContext, {
                'deletedTaskId': taskId,
                'deleted': true,
              });

              unawaited(
                _taskController.deleteTask(taskId).catchError((e) {
                  ScaffoldMessenger.of(
                    parentContext,
                  ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
                }),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalSubtasks = widget.task['totalSubtasks'] is int
        ? widget.task['totalSubtasks'] as int
        : 0;
    final completedSubtasks = widget.task['completedSubtasks'] is int
        ? widget.task['completedSubtasks'] as int
        : 0;
    final rawProgress = widget.task['progress'];
    int? progressPercent;
    if (rawProgress is num) {
      progressPercent = rawProgress.round().clamp(0, 100);
    } else if (rawProgress != null) {
      progressPercent = int.tryParse(rawProgress.toString())?.clamp(0, 100);
    }

    final rawTags = widget.task['tags'];
    final tags = rawTags is List
        ? rawTags
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList()
        : rawTags is String
        ? rawTags
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList()
        : <String>[];
    final startDateLabel = _formatDate(widget.task['startDate']?.toString());
    final dueDateTime = DateTime.tryParse(
      widget.task['dueDate']?.toString() ?? '',
    );
    final statusLabel = progressPercent != null && progressPercent >= 100
        ? 'Completed'
        : 'In Progress';

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 22),
        ),
        title: const Text(
          'Task Details',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Icon(
              Icons.person_outline,
              color: Colors.grey.shade700,
              size: 20,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              children: [
                if (tags.isNotEmpty) ...[
                  SizedBox(
                    height: 35,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            color: index == 0
                                ? const Color(0xFFFF6A1F)
                                : Color(0xffDDDBDC),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            tags[index],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: index == 0 ? Colors.white : Colors.black87,
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemCount: tags.length,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TaskOverviewCards(
                  title: widget.task['title']?.toString() ?? 'Task',
                  startDateLabel: startDateLabel,
                  dueDateLabel: _formatDueDate(
                    widget.task['dueDate']?.toString(),
                  ),
                  dueDateTime: dueDateTime,
                  priorityLabel: _getPriorityLabel(widget.task),
                  statusLabel: statusLabel,
                  totalSubtasks: totalSubtasks,
                  completedSubtasks: completedSubtasks,
                  progressPercent: progressPercent,
                ),
                const SizedBox(height: 14),

                TaskDescriptionCard(
                  description:
                      widget.task['description']?.toString() ??
                      'No description available for this task.',
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: TaskDetailsBottomBar(
        onEdit: () {},
        onDelete: _showDeleteConfirmation,
        onMarkCompleted: () {},
      ),
    );
  }
}
