import 'package:flutter/material.dart';

class HomeHighPriorityCard extends StatelessWidget {
  const HomeHighPriorityCard({super.key});

  Widget _dot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'High Priority',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Icon(Icons.more_horiz, color: Colors.grey.shade400, size: 18),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '01:00 2:20:88',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
          ),
          const Spacer(),
          Row(
            children: [
              _dot(Colors.red.shade400),
              const SizedBox(width: 5),
              _dot(Colors.orange.shade400),
              const SizedBox(width: 5),
              _dot(Colors.green.shade400),
              const SizedBox(width: 5),
              _dot(Colors.blue.shade300),
            ],
          ),
        ],
      ),
    );
  }
}
