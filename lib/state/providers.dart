import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/cms_repository.dart';
import '../data/epub/epub_book.dart';
import '../data/models.dart';

final cmsProvider = Provider((ref) => CmsRepository());

final catalogProvider = FutureProvider<Catalog>((ref) => ref.watch(cmsProvider).fetchCatalog());

final epubProvider = FutureProvider.family<EpubBook, String>((ref, file) => EpubBook.fromAsset(file));

// ---------------------------------------------------------------- session

class Session {
  const Session({this.signedIn = false, this.name = 'Mia', this.email = 'mia.harper@email.com.au', this.firstRun = false});
  final bool signedIn, firstRun;
  final String name, email;
  Session copyWith({bool? signedIn, bool? firstRun}) =>
      Session(signedIn: signedIn ?? this.signedIn, firstRun: firstRun ?? this.firstRun, name: name, email: email);
}

class SessionNotifier extends Notifier<Session> {
  @override
  Session build() => const Session();

  /// Existing reader: signs in with a seeded shelf, bookmarks and favourites.
  void signIn() {
    state = state.copyWith(signedIn: true, firstRun: false);
    ref.read(progressProvider.notifier).seed();
    ref.read(favouritesProvider.notifier).seed();
    ref.read(bookmarksProvider.notifier).seed();
  }

  /// New free account: empty shelf (first-run states).
  void createAccount() {
    state = state.copyWith(signedIn: true, firstRun: true);
    ref.read(progressProvider.notifier).clear();
  }

  void signOut() => state = const Session();
}

final sessionProvider = NotifierProvider<SessionNotifier, Session>(SessionNotifier.new);

// ---------------------------------------------------------------- membership

class MembershipNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void upgrade() => state = true;
  void reset() => state = false;
}

final premiumProvider = NotifierProvider<MembershipNotifier, bool>(MembershipNotifier.new);

/// Free accounts can open non-premium titles; premium unlocks everything.
final canOpenProvider = Provider.family<bool, Book>((ref, t) => !t.premium || ref.watch(premiumProvider));

// ---------------------------------------------------------------- reading + listening progress

class Progress {
  const Progress({required this.bookId, this.chapter = 0, this.page = 0, this.fraction = 0, this.audioLeft});
  final String bookId;
  final int chapter, page;
  final double fraction;
  final String? audioLeft;
}

class ProgressNotifier extends Notifier<Map<String, Progress>> {
  @override
  Map<String, Progress> build() => {};

  void seed() => state = {
    'salt-road': const Progress(bookId: 'salt-road', chapter: 6, fraction: .42),
    'harbour-lights': const Progress(bookId: 'harbour-lights', chapter: 2, fraction: .61, audioLeft: '2h 14m left'),
    'red-dirt-country': const Progress(bookId: 'red-dirt-country', fraction: .08),
    'notes-from-hobart': const Progress(bookId: 'notes-from-hobart', fraction: 1),
    'year-of-small-things': const Progress(bookId: 'year-of-small-things'),
    'quiet-coast': const Progress(bookId: 'quiet-coast'),
  };

  void clear() => state = {};

  void update(String id, {required int chapter, required int page, required double fraction}) =>
      state = {...state, id: Progress(bookId: id, chapter: chapter, page: page, fraction: fraction, audioLeft: state[id]?.audioLeft)};
}

final progressProvider = NotifierProvider<ProgressNotifier, Map<String, Progress>>(ProgressNotifier.new);

// ---------------------------------------------------------------- favourites + bookmarks

class FavouritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};
  void seed() => state = {'title:paper-trails', 'title:harbour-lights', 'daily:why-we-still-write-letters', 'ref:eureka-stockade', 'title:notes-from-hobart'};
  void toggle(String key) => state = state.contains(key) ? ({...state}..remove(key)) : {...state, key};
}

final favouritesProvider = NotifierProvider<FavouritesNotifier, Set<String>>(FavouritesNotifier.new);

class BookmarksNotifier extends Notifier<List<Bookmark>> {
  @override
  List<Bookmark> build() => [];

  void seed() => state = const [
    Bookmark(
      bookId: 'salt-road',
      chapter: 6,
      chapterTitle: 'The Long Paddock',
      page: 131,
      snippet: 'The paddock ran silver under the moon and the fence wire sang with the first cold gust off the bight.',
      when: 'Today',
    ),
    Bookmark(
      bookId: 'salt-road',
      chapter: 4,
      chapterTitle: 'Salt and Iron',
      page: 98,
      snippet: 'She paused by the iron gate, where rusted wire caught the morning mist like beaten copper.',
      when: '3 Nov',
    ),
    Bookmark(
      bookId: 'salt-road',
      chapter: 2,
      chapterTitle: 'The Coach Road',
      page: 54,
      snippet: 'The team rattled past the ghost gums at midday, dust rising in amber plumes behind the wheels.',
      when: '28 Oct',
    ),
    Bookmark(
      bookId: 'salt-road',
      chapter: 0,
      chapterTitle: 'Port Fairy',
      page: 9,
      snippet: 'The tide had pulled away from the stone jetty, leaving kelp and salt crust in the crevices.',
      when: '20 Oct',
    ),
  ];

  bool has(String bookId, int chapter, int page) => state.any((b) => b.bookId == bookId && b.chapter == chapter && b.page == page);

  void toggle(Bookmark b) {
    final exists = has(b.bookId, b.chapter, b.page);
    state = exists
        ? [
            for (final x in state)
              if (!(x.bookId == b.bookId && x.chapter == b.chapter && x.page == b.page)) x,
          ]
        : [b, ...state];
  }

  void remove(Bookmark b) => state = [
    for (final x in state)
      if (!identical(x, b)) x,
  ];
}

final bookmarksProvider = NotifierProvider<BookmarksNotifier, List<Bookmark>>(BookmarksNotifier.new);

// ---------------------------------------------------------------- reader settings

enum ReaderTheme { white, paper, sepia, night }

class ReaderSettings {
  const ReaderSettings({
    this.fontSize = 18,
    this.family = 'Original',
    this.theme = ReaderTheme.paper,
    this.lineHeight = 1.6,
    this.margin = 28,
    this.scroll = false,
  });
  final double fontSize, lineHeight, margin;
  final String family;
  final ReaderTheme theme;
  final bool scroll;

  ReaderSettings copyWith({double? fontSize, String? family, ReaderTheme? theme, double? lineHeight, double? margin, bool? scroll}) => ReaderSettings(
    fontSize: fontSize ?? this.fontSize,
    family: family ?? this.family,
    theme: theme ?? this.theme,
    lineHeight: lineHeight ?? this.lineHeight,
    margin: margin ?? this.margin,
    scroll: scroll ?? this.scroll,
  );

  Color get background => switch (theme) {
    ReaderTheme.white => Colors.white,
    ReaderTheme.paper => const Color(0xFFFBF6EE),
    ReaderTheme.sepia => const Color(0xFFF4ECD8),
    ReaderTheme.night => const Color(0xFF1F191B),
  };
  Color get ink => theme == ReaderTheme.night ? const Color(0xFFEDE3E6) : const Color(0xFF1F0C11);
  Color get muted => theme == ReaderTheme.night ? const Color(0xFFB9A9AE) : const Color(0xFF5C454C);
  String? get fontFamily => switch (family) {
    'Serif' => 'Georgia',
    'Sans' => null,
    'Dyslexic-friendly' => 'MPlusRounded',
    _ => 'MPlusRounded',
  };
  double get letterSpacing => family == 'Dyslexic-friendly' ? 0.6 : 0;
}

class ReaderSettingsNotifier extends Notifier<ReaderSettings> {
  @override
  ReaderSettings build() => const ReaderSettings();
  void set(ReaderSettings s) => state = s;
}

final readerSettingsProvider = NotifierProvider<ReaderSettingsNotifier, ReaderSettings>(ReaderSettingsNotifier.new);

// ---------------------------------------------------------------- downloads

class DownloadItem {
  const DownloadItem({required this.bookId, required this.kind, required this.mb, this.progress = 1, this.paused = false});
  final String bookId, kind;
  final int mb;
  final double progress;
  final bool paused;
  bool get done => progress >= 1;
  DownloadItem copyWith({double? progress, bool? paused}) =>
      DownloadItem(bookId: bookId, kind: kind, mb: mb, progress: progress ?? this.progress, paused: paused ?? this.paused);
}

class DownloadsNotifier extends Notifier<List<DownloadItem>> {
  Timer? _t;

  @override
  List<DownloadItem> build() {
    ref.onDispose(() => _t?.cancel());
    return const [
      DownloadItem(bookId: 'salt-road', kind: 'Ebook', mb: 4),
      DownloadItem(bookId: 'harbour-lights', kind: 'Audiobook', mb: 812, progress: .64),
      DownloadItem(bookId: 'notes-from-hobart', kind: 'Audiobook', mb: 380),
    ];
  }

  void togglePause(String id) {
    state = [for (final d in state) d.bookId == id ? d.copyWith(paused: !d.paused) : d];
    _tick();
  }

  /// Simulated background download (a real build uses a resumable HTTP range download).
  void _tick() {
    _t?.cancel();
    if (!state.any((d) => !d.done && !d.paused)) return;
    _t = Timer.periodic(const Duration(milliseconds: 400), (_) {
      state = [for (final d in state) (!d.done && !d.paused) ? d.copyWith(progress: (d.progress + .03).clamp(0, 1)) : d];
      if (!state.any((d) => !d.done && !d.paused)) _t?.cancel();
    });
  }

  void remove(String id) => state = [
    for (final d in state)
      if (d.bookId != id) d,
  ];
  void clear() => state = [];
}

final downloadsProvider = NotifierProvider<DownloadsNotifier, List<DownloadItem>>(DownloadsNotifier.new);

class WifiOnlyNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void toggle() => state = !state;
}

final wifiOnlyProvider = NotifierProvider<WifiOnlyNotifier, bool>(WifiOnlyNotifier.new);
