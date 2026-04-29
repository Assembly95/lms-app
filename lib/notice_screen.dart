import 'package:flutter/material.dart';
import 'notice_detail_screen.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notices = [
      {'title': '5월 1일 휴원 안내', 'date': '2026-04-30'},
      {'title': '숙제 제출 방식 변경', 'date': '2026-04-28'},
      {'title': '코딩 테스트 일정 공지', 'date': '2026-04-25'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('공지사항')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notices.length,
        itemBuilder: (context, index) {
          final item = notices[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoticeDetailScreen(
                    title: item['title']!,
                    date: item['date']!,
                    content: '여기에 공지 내용',
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['date']!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
