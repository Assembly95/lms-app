import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'notice_detail_screen.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> notices = [];

  @override
  void initState() {
    super.initState();
    loadNotices();
  }

  Future<void> loadNotices() async {
    final Uri url = Uri.parse('http://localhost:8089/api/app/notices');

    try {
      final http.Response response = await http.get(url);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          notices = data.map((item) {
            return {
              'noticeId': item['noticeId'],
              'title': item['title'] ?? '제목 없음',
              'content': item['content'] ?? '',
              'writerName': item['writerName'] ?? '',
              'createdAt': item['createdAt'],
              'thumbnailUrl': item['thumbnailUrl'],
            };
          }).toList();
          isLoading = false;
        });

        print('공지사항 조회 성공: $data');
      } else {
        setState(() {
          isLoading = false;
        });
        print('공지사항 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
      print('공지사항 조회 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('공지사항')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notices.isEmpty
          ? const Center(child: Text('등록된 공지사항이 없습니다.'))
          : ListView.builder(
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
                          title: item['title'],
                          date: _formatDate(item['createdAt']),
                          content: item['content'],
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
                          item['title'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatDate(item['createdAt']),
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

  String _formatDate(String? dateText) {
    if (dateText == null) {
      return '';
    }

    final DateTime date = DateTime.parse(dateText);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _stripHtml(String? htmlText) {
    if (htmlText == null || htmlText.isEmpty) return '';

    return htmlText
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</div>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\n\s*\n\s*\n+'), '\n\n')
        .trim();
  }
}
