import 'package:flutter/material.dart';

class AssignmentScreen extends StatelessWidget {
  const AssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final assignments = [
      {'title': '반복문 문제 풀기', 'due': 'D-1', 'status': '미제출'},
      {'title': '배열 문제 5개', 'due': 'D-3', 'status': '제출'},
      {'title': '함수 개념 정리', 'due': 'D-0', 'status': '미제출'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('숙제')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: assignments.length,
        itemBuilder: (context, index) {
          final item = assignments[index];

          return _assignmentCard(item);
        },
      ),
    );
  }

  Widget _assignmentCard(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['title']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(item['due']!, style: const TextStyle(color: Colors.grey)),
            ],
          ),

          _statusChip(item['status']!),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;

    if (status == '미제출') {
      color = Colors.red;
    } else {
      color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
