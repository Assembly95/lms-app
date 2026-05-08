import 'package:flutter/material.dart';

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
    final List<Widget> widgets = [];

    final RegExp imageRegExp = RegExp(
      '<img[^>]+src=["\\\']([^"\\\']+)["\\\'][^>]*>',
      caseSensitive: false,
    );

    int currentIndex = 0;

    for (final RegExpMatch match in imageRegExp.allMatches(htmlText)) {
      final String beforeImage = htmlText.substring(currentIndex, match.start);

      final String cleanText = _stripHtml(beforeImage);

      if (cleanText.isNotEmpty) {
        widgets.add(_textBlock(cleanText));
        widgets.add(const SizedBox(height: 20));
      }

      final String? imageSrc = match.group(1);
      final String? imageUrl = _getFullImageUrl(imageSrc);
      debugPrint('공지 이미지 URL: $imageUrl');

      if (imageUrl != null) {
        widgets.add(
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('공지 이미지 로드 실패: $imageUrl');
                debugPrint('오류: $error');
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('이미지를 불러올 수 없습니다.'),
                );
              },
            ),
          ),
        );

        widgets.add(const SizedBox(height: 20));
      }

      currentIndex = match.end;
    }

    final String remainingText = htmlText.substring(currentIndex);
    final String cleanRemainingText = _stripHtml(remainingText);

    if (cleanRemainingText.isNotEmpty) {
      widgets.add(_textBlock(cleanRemainingText));
    }

    if (widgets.isEmpty) {
      widgets.add(_textBlock(_stripHtml(htmlText)));
    }

    return widgets;
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
