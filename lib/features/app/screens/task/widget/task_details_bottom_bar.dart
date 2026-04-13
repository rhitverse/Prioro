import 'package:flutter/material.dart';

class TaskDetailsBottomBar extends StatelessWidget {
  final VoidCallback onMarkCompleted;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isOverdueTask;

  const TaskDetailsBottomBar({
    super.key,
    required this.onMarkCompleted,
    required this.onEdit,
    required this.onDelete,
    this.isOverdueTask = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                height: 54,
                width: 190,
                child: ElevatedButton(
                  onPressed: isOverdueTask ? null : onMarkCompleted,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOverdueTask
                        ? const Color(0xFFE4574F)
                        : const Color(0xFFFF6A1F),
                    disabledBackgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: Text(
                    isOverdueTask ? 'Overdue' : 'Mark as Completed',
                    style: TextStyle(
                      fontSize: isOverdueTask ? 16 : 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 50),
              GestureDetector(
                onTap: onEdit,
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 40),
              GestureDetector(
                onTap: onDelete,
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE53935),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
