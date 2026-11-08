import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inkwell/data/epub/epub_book.dart';
import 'package:inkwell/data/epub/paginator.dart';

void main() {
  test('parses the bundled EPUB via container.xml, OPF and spine', () {
    final book = EpubBook.parse(File('assets/books/salt-road.epub').readAsBytesSync());
    expect(book.title, 'The Salt Road');
    expect(book.author, 'Eleanor Marsh');
    expect(book.chapters, hasLength(8));
    expect(book.chapters[6].title, 'The Long Paddock');
    expect(book.chapters[6].paragraphs.first, startsWith('The frost had settled'));
  });

  test('larger text produces more pages and no text is lost', () {
    final book = EpubBook.parse(File('assets/books/salt-road.epub').readAsBytesSync());
    List<ReaderPage> pages(double size) => Paginator.paginate(book,
        area: const Size(330, 520), style: TextStyle(fontSize: size, height: 1.6), paragraphGap: size * .8, headingHeight: 96);
    final small = pages(14), large = pages(24);
    expect(large.length, greaterThan(small.length));
    final words = book.chapters.expand((c) => c.paragraphs).join(' ').split(' ').length;
    final paged = large.expand((p) => p.paragraphs).join(' ').split(' ').length;
    expect(paged, words);
  });
}
