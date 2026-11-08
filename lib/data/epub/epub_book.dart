import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

class EpubChapter {
  const EpubChapter({required this.title, required this.paragraphs});
  final String title;
  final List<String> paragraphs;
}

class EpubBook {
  const EpubBook({required this.title, required this.author, required this.chapters});
  final String title, author;
  final List<EpubChapter> chapters;

  /// Parses an EPUB 2/3 package: container.xml -> OPF -> spine -> XHTML.
  static EpubBook parse(List<int> bytes) {
    final zip = ZipDecoder().decodeBytes(bytes);
    String read(String path) {
      final f = zip.findFile(path);
      if (f == null) throw FormatException('EPUB missing $path');
      return String.fromCharCodes(f.content as List<int>);
    }

    final container = XmlDocument.parse(read('META-INF/container.xml'));
    final opfPath = container.findAllElements('rootfile').first.getAttribute('full-path')!;
    final base = opfPath.contains('/') ? opfPath.substring(0, opfPath.lastIndexOf('/') + 1) : '';
    final opf = XmlDocument.parse(read(opfPath));

    String meta(String name) => opf.findAllElements(name, namespaceUri: '*').map((e) => e.innerText.trim()).firstOrNull ?? '';
    final manifest = {for (final item in opf.findAllElements('item', namespaceUri: '*')) item.getAttribute('id')!: item.getAttribute('href')!};

    final chapters = <EpubChapter>[];
    for (final ref in opf.findAllElements('itemref', namespaceUri: '*')) {
      final href = manifest[ref.getAttribute('idref')];
      if (href == null) continue;
      final doc = XmlDocument.parse(read('$base$href'));
      final heading =
          doc.findAllElements('h1', namespaceUri: '*').firstOrNull?.innerText.trim() ??
          doc.findAllElements('title', namespaceUri: '*').firstOrNull?.innerText.trim() ??
          'Chapter ${chapters.length + 1}';
      final paras = [
        for (final p in doc.findAllElements('p', namespaceUri: '*'))
          if (p.innerText.trim().isNotEmpty) p.innerText.replaceAll(RegExp(r'\s+'), ' ').trim(),
      ];
      chapters.add(EpubChapter(title: heading, paragraphs: paras));
    }
    return EpubBook(title: meta('title'), author: meta('creator'), chapters: chapters);
  }

  static Future<EpubBook> fromAsset(String file, {AssetBundle? bundle}) async {
    final data = await (bundle ?? rootBundle).load('assets/books/$file');
    return parse(data.buffer.asUint8List());
  }
}
