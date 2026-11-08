import 'package:flutter/painting.dart';

import 'epub_book.dart';

/// A slice of one chapter that fits on a single screen page.
class ReaderPage {
  const ReaderPage({required this.chapter, required this.paragraphs, required this.startsChapter, required this.firstIsContinuation});
  final int chapter;
  final List<String> paragraphs;
  final bool startsChapter;
  final bool firstIsContinuation;
}

/// Splits chapters into pages by measuring text with [TextPainter], so page
/// count follows font size, line spacing and margins like a real reader.
class Paginator {
  static List<ReaderPage> paginate(EpubBook book, {required Size area, required TextStyle style, required double paragraphGap, required double headingHeight}) {
    final pages = <ReaderPage>[];
    for (var ci = 0; ci < book.chapters.length; ci++) {
      var current = <String>[];
      var used = headingHeight;
      var starts = true;
      var continuation = false;
      var firstContinuation = false;

      void flush() {
        pages.add(ReaderPage(chapter: ci, paragraphs: current, startsChapter: starts, firstIsContinuation: firstContinuation));
        current = [];
        used = 0;
        starts = false;
        firstContinuation = continuation;
      }

      for (final para in book.chapters[ci].paragraphs) {
        var rest = para;
        while (rest.isNotEmpty) {
          final h = _height(rest, style, area.width);
          if (used + h <= area.height) {
            current.add(rest);
            used += h + paragraphGap;
            continuation = false;
            rest = '';
          } else {
            final fit = _fitWords(rest, style, area.width, area.height - used);
            if (fit.isEmpty) {
              flush();
              continue;
            }
            current.add(fit);
            rest = rest.substring(fit.length).trimLeft();
            continuation = true;
            flush();
          }
        }
      }
      if (current.isNotEmpty || starts) flush();
    }
    return pages;
  }

  static double _height(String text, TextStyle style, double width) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width);
    return tp.height;
  }

  static String _fitWords(String text, TextStyle style, double width, double maxHeight) {
    final words = text.split(' ');
    var lo = 0, hi = words.length;
    while (lo < hi) {
      final mid = (lo + hi + 1) ~/ 2;
      if (_height(words.take(mid).join(' '), style, width) <= maxHeight) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return words.take(lo).join(' ');
  }
}
