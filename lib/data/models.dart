enum Format { ebook, audiobook }

class Chapter {
  const Chapter({required this.n, required this.title, required this.seconds});
  final int n;
  final String title;
  final int seconds;

  factory Chapter.fromJson(Map<String, dynamic> j) => Chapter(n: j['n'], title: j['title'], seconds: j['seconds']);
}

class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.cover,
    required this.formats,
    required this.premium,
    required this.rating,
    required this.ratings,
    required this.genres,
    required this.blurb,
    this.epub,
    this.audio,
    this.pages,
    this.audioMinutes,
    this.narrator,
    this.narratorPhoto,
    this.chapters = const [],
  });

  final String id, title, author, cover, blurb;
  final Set<Format> formats;
  final bool premium;
  final double rating;
  final int ratings;
  final List<String> genres;
  final String? epub, audio, narrator, narratorPhoto;
  final int? pages, audioMinutes;
  final List<Chapter> chapters;

  bool get isEbook => formats.contains(Format.ebook);
  bool get isAudio => formats.contains(Format.audiobook);
  String get coverAsset => 'assets/images/$cover.jpg';

  String get audioLength {
    final m = audioMinutes ?? 0;
    return '${m ~/ 60}h ${(m % 60).toString().padLeft(2, '0')}m';
  }

  factory Book.fromJson(Map<String, dynamic> j) => Book(
    id: j['id'],
    title: j['title'],
    author: j['author'],
    cover: j['cover'],
    formats: {for (final f in (j['formats'] as List)) Format.values.byName(f)},
    premium: j['premium'] ?? false,
    rating: (j['rating'] as num).toDouble(),
    ratings: j['ratings'] ?? 0,
    genres: List<String>.from(j['genres'] ?? const []),
    blurb: j['blurb'] ?? '',
    epub: j['epub'],
    audio: j['audio'],
    pages: j['pages'],
    audioMinutes: j['audioMinutes'],
    narrator: j['narrator'],
    narratorPhoto: j['narratorPhoto'],
    chapters: [for (final c in (j['chapters'] as List? ?? const [])) Chapter.fromJson(c)],
  );
}

class DailyPiece {
  const DailyPiece({
    required this.id,
    required this.date,
    required this.kicker,
    required this.title,
    required this.author,
    required this.authorPhoto,
    required this.hero,
    required this.minutes,
    required this.body,
    this.audio,
    this.relatedTitle,
  });

  final String id, date, kicker, title, author, authorPhoto, hero;
  final int minutes;
  final List<String> body;
  final String? audio, relatedTitle;

  factory DailyPiece.fromJson(Map<String, dynamic> j) => DailyPiece(
    id: j['id'],
    date: j['date'],
    kicker: j['kicker'],
    title: j['title'],
    author: j['author'],
    authorPhoto: j['authorPhoto'],
    hero: j['hero'],
    minutes: j['minutes'],
    body: List<String>.from(j['body']),
    audio: j['audio'],
    relatedTitle: j['relatedTitle'],
  );
}

class ReferenceEntry {
  const ReferenceEntry({
    required this.id,
    required this.title,
    required this.year,
    required this.path,
    required this.photo,
    required this.facts,
    required this.summary,
    required this.body,
    required this.related,
    required this.seeAlso,
  });

  final String id, title, year, photo, summary;
  final List<String> path, body, related, seeAlso;
  final List<(String, String)> facts;

  factory ReferenceEntry.fromJson(Map<String, dynamic> j) => ReferenceEntry(
    id: j['id'],
    title: j['title'],
    year: j['year'],
    path: List<String>.from(j['path']),
    photo: j['photo'],
    facts: [for (final f in (j['facts'] as List)) (f[0] as String, f[1] as String)],
    summary: j['summary'],
    body: List<String>.from(j['body']),
    related: List<String>.from(j['related']),
    seeAlso: List<String>.from(j['seeAlso']),
  );
}

class Catalog {
  const Catalog({required this.version, required this.titles, required this.daily, required this.reference});
  final String version;
  final List<Book> titles;
  final List<DailyPiece> daily;
  final List<ReferenceEntry> reference;

  Book title(String id) => titles.firstWhere((t) => t.id == id);
  ReferenceEntry ref(String id) => reference.firstWhere((r) => r.id == id);
  DailyPiece piece(String id) => daily.firstWhere((d) => d.id == id);

  factory Catalog.fromJson(Map<String, dynamic> j) => Catalog(
    version: j['version'],
    titles: [for (final t in j['titles']) Book.fromJson(t)],
    daily: [for (final d in j['daily']) DailyPiece.fromJson(d)],
    reference: [for (final r in j['reference']) ReferenceEntry.fromJson(r)],
  );
}

/// One search hit across the four content types.
class SearchHit {
  const SearchHit({required this.kind, required this.id, required this.title, required this.subtitle, required this.image});
  final String kind; // ebook | audiobook | daily | reference
  final String id, title, subtitle, image;
}

class Bookmark {
  const Bookmark({required this.bookId, required this.chapter, required this.chapterTitle, required this.page, required this.snippet, required this.when});
  final String bookId, chapterTitle, snippet, when;
  final int chapter, page;
}
