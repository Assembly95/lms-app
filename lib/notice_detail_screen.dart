import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NoticeDetailScreen extends StatelessWidget {
  final String title;
  final String date;
  final String content;

  const NoticeDetailScreen({
    super.key,
    required this.title,
    required this.date,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('공지사항')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                date,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 28),
              ..._buildContentWidgets(content),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContentWidgets(String htmlText) {
    final List<Widget> imageWidgets = [];
    final List<Widget> textWidgets = [];

    final RegExp imageRegExp = RegExp(
      '<img[^>]+src=["\\\']([^"\\\']+)["\\\'][^>]*>',
      caseSensitive: false,
    );

    int currentIndex = 0;

    for (final RegExpMatch match in imageRegExp.allMatches(htmlText)) {
      final String beforeImage = htmlText.substring(currentIndex, match.start);
      final String cleanText = _stripHtml(beforeImage);

      if (cleanText.isNotEmpty) {
        textWidgets.add(_textBlock(cleanText));
        textWidgets.add(const SizedBox(height: 20));
      }

      final String? imageSrc = match.group(1);
      final String? imageUrl = _getFullImageUrl(imageSrc);
      debugPrint('공지 이미지 URL: $imageUrl');

      if (imageUrl != null) {
        imageWidgets.add(
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _noticeImage(imageUrl),
          ),
        );

        imageWidgets.add(const SizedBox(height: 20));
      }

      currentIndex = match.end;
    }

    final String remainingText = htmlText.substring(currentIndex);
    final String cleanRemainingText = _stripHtml(remainingText);

    if (cleanRemainingText.isNotEmpty) {
      textWidgets.add(_textBlock(cleanRemainingText));
    }

    if (imageWidgets.isEmpty && textWidgets.isEmpty) {
      textWidgets.add(_textBlock(_stripHtml(htmlText)));
    }

    return [...imageWidgets, ...textWidgets];
  }

  Widget _noticeImage(String imageUrl) {
    return FutureBuilder<Uint8List?>(
      future: _loadImageBytes(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            height: 180,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('이미지를 불러올 수 없습니다.'),
          );
        }

        return Image.memory(
          snapshot.data!,
          width: double.infinity,
          fit: BoxFit.contain,
        );
      },
    );
  }

  Future<Uint8List?> _loadImageBytes(String imageUrl) async {
    try {
      final http.Response response = await http.get(Uri.parse(imageUrl));

      debugPrint('공지 이미지 응답 URL: $imageUrl');
      debugPrint('공지 이미지 응답 status: ${response.statusCode}');
      debugPrint('공지 이미지 응답 content-type: ${response.headers['content-type']}');
      debugPrint('공지 이미지 응답 length: ${response.bodyBytes.length}');

      if (response.bodyBytes.length >= 8) {
        debugPrint('공지 이미지 앞 8바이트: ${response.bodyBytes.take(8).toList()}');
      }

      if (response.statusCode != 200) {
        return null;
      }

      return response.bodyBytes;
    } catch (e) {
      debugPrint('공지 이미지 바이트 로드 실패: $e');
      return null;
    }
  }

  Widget _textBlock(String text) {
    return Text(text, style: const TextStyle(fontSize: 17, height: 1.6));
  }

  String? _getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    if (imagePath.startsWith('http')) {
      return imagePath.replaceFirst('/comFileDownload', '/comFileView');
    }

    final String viewPath = imagePath.replaceFirst(
      '/comFileDownload',
      '/comFileView',
    );

    return 'https://lms.itpleedu.com$viewPath';
  }

  String _stripHtml(String? htmlText) {
    if (htmlText == null || htmlText.isEmpty) {
      return '';
    }

    return htmlText
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</div>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '• ')
        .replaceAll(RegExp(r'</li>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\n\s*\n\s*\n+'), '\n\n')
        .trim();
  }
}
