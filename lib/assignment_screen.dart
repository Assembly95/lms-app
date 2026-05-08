import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'assignment_detail_screen.dart';

class AssignmentScreen extends StatefulWidget {
  final int userNo;

  const AssignmentScreen({super.key, required this.userNo});

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> assignments = [];

  @override
  void initState() {
    super.initState();
    loadAssignments();
  }

  Future<void> loadAssignments() async {
    final DateTime now = DateTime.now();
    final Uri url = Uri.parse(
      'http://localhost:8089/api/app/assignments?userNo=${widget.userNo}&year=${now.year}&month=${now.month}',
    );

    try {
      final http.Response response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          assignments = data.map((item) {
            return {
              'assignmentId': item['assignmentId'],
              'title': item['title'] ?? '제목 없음',
              'content': item['content'] ?? '',
              'deadline': item['deadline'],
              'status': item['status'] ?? '미제출',
              'closed': item['closed'] ?? false,
            };
          }).toList();
          isLoading = false;
        });

        print('숙제 목록 조회 성공: $data');
      } else {
        setState(() {
          isLoading = false;
        });
        print('숙제 목록 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
      print('숙제 목록 조회 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('숙제')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : assignments.isEmpty
          ? const Center(child: Text('등록된 숙제가 없습니다.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final item = assignments[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssignmentDetailScreen(
                          title: item['title'],
                          due: _formatDueText(item['deadline'], item['closed']),
                          status: item['status'],
                          content: item['content'],
                        ),
                      ),
                    );
                  },
                  child: _assignmentCard(item),
                );
              },
            ),
    );
  }

  Widget _assignmentCard(Map<String, dynamic> item) {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDueText(item['deadline'], item['closed']),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _statusChip(item['status'], item['closed']),
        ],
      ),
    );
  }

  String _formatDueText(String? deadline, bool closed) {
    if (deadline == null) {
      return '기한 없음';
    }

    final DateTime dueDate = DateTime.parse(deadline);
    final DateTime today = DateTime.now();
    final DateTime dueOnlyDate = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
    );
    final DateTime todayOnlyDate = DateTime(today.year, today.month, today.day);
    final int diffDays = dueOnlyDate.difference(todayOnlyDate).inDays;

    if (closed || diffDays < 0) {
      return '기한 마감';
    }

    if (diffDays == 0) {
      return 'D-Day';
    }

    return 'D-$diffDays';
  }

  Widget _statusChip(String status, bool closed) {
    Color color;
    String label = status;

    if (closed && status == '미제출') {
      color = Colors.red;
      label = '기한 마감';
    } else if (status == '미제출') {
      color = Colors.grey;
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
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
