import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeUpcomingTaskCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final Color taskColor;
  final String dueDateText;
  final VoidCallback onTap;

  const HomeUpcomingTaskCard({
    super.key,
    required this.task,
    required this.taskColor,
    required this.dueDateText,
    required this.onTap,
  });

  String _getCalendarSvg(Color color) {
    if (color == Colors.red) {
      return 'assets/svg/highCalendar.svg';
    } else if (color == Colors.orange) {
      return 'assets/svg/orangeCalendar.svg';
    } else if (color == Colors.green) {
      return 'assets/svg/greenCalendar.svg';
    }
    return 'assets/svg/greyCalendar.svg';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                _getCalendarSvg(taskColor),
                width: 48,
                height: 48,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          task['title']?.toString() ?? 'No title',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        dueDateText,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task['description']?.toString().isNotEmpty == true
                        ? task['description'].toString()
                        : 'No description',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
