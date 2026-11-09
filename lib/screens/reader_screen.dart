import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/epub/epub_book.dart';
import '../data/epub/paginator.dart';
import '../data/models.dart';
import '../state/audio_controller.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

/// Passages the reader has highlighted (seeded for the demo account).
const _highlights = [
  'She knew every post by heart, the split red gum, the ironbark weathered to silver, the notch her father had cut the summer the drought finally broke.',
];

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.id, this.sheet, this.chapter});
  final String id;
  final String? sheet;
  final int? chapter;
  @override
  ConsumerState<ReaderScreen> createState() => _ReaderState();
}

class _ReaderState extends ConsumerState<ReaderScreen> {
  PageController? _pc;
  List<ReaderPage> _pages = const [];
  String _layoutKey = '';
  int _page = 0;
  bool _sheetShown = false;

  TextStyle _style(ReaderSettings s) =>
      TextStyle(fontFamily: s.fontFamily, fontSize: s.fontSize, height: s.lineHeight, letterSpacing: s.letterSpacing, color: s.ink);

  void _repaginate(EpubBook book, Size area, ReaderSettings s) {
    final key = '${area.width.round()}x${area.height.round()}-${s.fontSize}-${s.family}-${s.lineHeight}-${s.margin}';
    if (key == _layoutKey) return;
    final keepChapter = _pages.isEmpty ? null : _pages[_page.clamp(0, _pages.length - 1)].chapter;
    _layoutKey = key;
    _pages = Paginator.paginate(book, area: area, style: _style(s), paragraphGap: s.fontSize * .8, headingHeight: 96);
    final startChapter = keepChapter ?? widget.chapter ?? ref.read(progressProvider)[widget.id]?.chapter ?? 0;
    _page = _pages.indexWhere((p) => p.chapter == startChapter).clamp(0, _pages.length - 1);
    _pc?.dispose();
    _pc = PageController(initialPage: _page);
  }

  void _onPage(int i, EpubBook book) {
    setState(() => _page = i);
    ref.read(progressProvider.notifier).update(widget.id, chapter: _pages[i].chapter, page: i + 1, fraction: (i + 1) / _pages.length);
  }

  @override
  void dispose() {
    _pc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(catalogProvider).value;
    if (c == null) return const Scaffold();
    final t = c.title(widget.id);
    final s = ref.watch(readerSettingsProvider);
    final book = ref.watch(epubProvider(t.epub!));
    return Scaffold(
      backgroundColor: s.background,
      body: SafeArea(
        child: book.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Could not open EPUB: $e')),
          data: (b) => LayoutBuilder(
            builder: (context, box) {
              const chrome = 64.0, footer = 132.0;
              _repaginate(b, Size(box.maxWidth - s.margin * 2, box.maxHeight - chrome - footer - 8), s);
              if (widget.sheet == 'settings' && !_sheetShown) {
                _sheetShown = true;
                WidgetsBinding.instance.addPostFrameCallback((_) => showReaderSettings(context));
              }
              final page = _pages[_page.clamp(0, _pages.length - 1)];
              final chapter = b.chapters[page.chapter];
              final marked = ref.watch(bookmarksProvider.select((l) => l.any((x) => x.bookId == t.id && x.chapter == page.chapter && x.page == _page + 1)));
              return Column(
                children: [
                  SizedBox(
                    height: chrome,
                    child: Row(
                      children: [
                        IconButton(
                          key: const ValueKey('back'),
                          onPressed: () => context.pop(),
                          icon: Icon(Icons.arrow_back_ios_new_rounded, color: s.muted),
                        ),
                        Expanded(
                          child: Text(
                            'Chapter ${page.chapter + 1} · ${chapter.title}',
                            style: T.caption.copyWith(color: s.muted, fontWeight: FontWeight.w700),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          key: const ValueKey('contents'),
                          tooltip: 'Contents',
                          onPressed: () => context.push('/read/${t.id}/contents'),
                          icon: Icon(Icons.format_list_bulleted_rounded, color: s.muted),
                        ),
                        IconButton(
                          key: const ValueKey('bookmark'),
                          tooltip: 'Bookmark',
                          onPressed: () => ref
                              .read(bookmarksProvider.notifier)
                              .toggle(
                                Bookmark(
                                  bookId: t.id,
                                  chapter: page.chapter,
                                  chapterTitle: chapter.title,
                                  page: _page + 1,
                                  snippet: page.paragraphs.isEmpty ? '' : page.paragraphs.first,
                                  when: 'Just now',
                                ),
                              ),
                          icon: Icon(marked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: marked ? Pal.accent : s.muted),
                        ),
                        TextButton(
                          key: const ValueKey('aa'),
                          onPressed: () => showReaderSettings(context),
                          child: Text('Aa', style: T.title.copyWith(color: s.muted, fontSize: 18)),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  Expanded(
                    child: s.scroll
                        ? _ScrollChapter(chapter: chapter, title: t.title, settings: s, style: _style(s))
                        : PageView.builder(
                            key: ValueKey(_layoutKey),
                            controller: _pc,
                            itemCount: _pages.length,
                            onPageChanged: (i) => _onPage(i, b),
                            itemBuilder: (_, i) => _PageBody(page: _pages[i], book: b, settings: s, style: _style(s), bookTitle: t.title),
                          ),
                  ),
                  SizedBox(
                    height: footer,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: s.margin - 8),
                      child: Column(
                        children: [
                          if (t.isAudio)
                            Pill(
                              'Switch to audio at this spot',
                              icon: Icons.headphones_rounded,
                              keyName: 'switch-audio',
                              onTap: () async {
                                await ref.read(audioProvider.notifier).open(t, chapterIndex: page.chapter, start: Duration.zero);
                                if (context.mounted) context.push('/player');
                              },
                            ),
                          const Spacer(),
                          Slider(
                            value: (_page + 1) / _pages.length,
                            onChanged: (v) => _pc?.jumpToPage(((v * _pages.length).round() - 1).clamp(0, _pages.length - 1)),
                          ),
                          Text(
                            'Page ${_page + 1} of ${_pages.length} · ${_minutesLeft(page.chapter)} min left in chapter',
                            style: T.caption.copyWith(color: s.muted),
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  int _minutesLeft(int chapter) {
    final left = _pages.skip(_page).where((p) => p.chapter == chapter).length;
    return (left * 1.6).ceil();
  }
}

class _PageBody extends StatelessWidget {
  const _PageBody({required this.page, required this.book, required this.settings, required this.style, required this.bookTitle});
  final ReaderPage page;
  final EpubBook book;
  final ReaderSettings settings;
  final TextStyle style;
  final String bookTitle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: settings.margin),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (page.startsChapter)
          SizedBox(
            height: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  bookTitle.toUpperCase(),
                  style: T.caption.copyWith(color: settings.muted, letterSpacing: 1.2, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text('${_roman(page.chapter + 1)}. ${book.chapters[page.chapter].title}', style: T.title.copyWith(color: settings.ink, fontSize: 24)),
                const SizedBox(height: 10),
                Divider(height: 1, color: settings.muted.withValues(alpha: .25)),
              ],
            ),
          ),
        for (final p in page.paragraphs)
          Padding(
            padding: EdgeInsets.only(bottom: settings.fontSize * .8),
            child: _Para(p, style: style),
          ),
      ],
    ),
  );
}

class _ScrollChapter extends StatelessWidget {
  const _ScrollChapter({required this.chapter, required this.title, required this.settings, required this.style});
  final EpubChapter chapter;
  final String title;
  final ReaderSettings settings;
  final TextStyle style;
  @override
  Widget build(BuildContext context) => ListView(
    padding: EdgeInsets.symmetric(horizontal: settings.margin, vertical: 8),
    children: [
      Text(chapter.title, style: T.title.copyWith(color: settings.ink, fontSize: 24)),
      const SizedBox(height: 16),
      for (final p in chapter.paragraphs)
        Padding(
          padding: EdgeInsets.only(bottom: settings.fontSize * .8),
          child: _Para(p, style: style),
        ),
    ],
  );
}

class _Para extends StatelessWidget {
  const _Para(this.text, {required this.style});
  final String text;
  final TextStyle style;
  @override
  Widget build(BuildContext context) {
    final h = _highlights.where((x) => text.contains(x) || x.startsWith(text) || text.startsWith(x.substring(0, 40))).firstOrNull;
    if (h == null) return Text(text, style: style);
    return Text.rich(
      TextSpan(
        text: text,
        style: style.copyWith(backgroundColor: const Color(0x73B6E36A)),
      ),
    );
  }
}

String _roman(int n) => const ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI', 'XII'][n - 1];

Future<void> showReaderSettings(BuildContext context) => showModalBottomSheet(
  context: context,
  backgroundColor: Colors.white,
  barrierColor: const Color(0x661F0C11),
  isScrollControlled: true,
  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
  builder: (_) => const _SettingsSheet(),
);

class _SettingsSheet extends ConsumerWidget {
  const _SettingsSheet();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(readerSettingsProvider);
    void set(ReaderSettings v) => ref.read(readerSettingsProvider.notifier).set(v);
    Widget label(String t) => Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(t, style: T.label.copyWith(color: Pal.text2)),
    );
    Widget seg<V>(List<(V, IconData)> opts, V value, void Function(V) on) => Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Pal.surfaceAlt, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          for (final o in opts)
            Expanded(
              child: GestureDetector(
                onTap: () => on(o.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 40,
                  decoration: BoxDecoration(
                    color: o.$1 == value ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: o.$1 == value ? Pal.shadow : null,
                  ),
                  child: Icon(o.$2, color: o.$1 == value ? Pal.accentFill : Pal.text2),
                ),
              ),
            ),
        ],
      ),
    );
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Pal.border, borderRadius: BorderRadius.circular(9)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Display', style: T.title.copyWith(fontFamily: Pal.display, fontSize: 22)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Pal.text2),
                ),
              ],
            ),
            Row(
              children: [
                Text('A', style: T.label.copyWith(color: Pal.text2)),
                Expanded(
                  child: Slider(
                    key: const ValueKey('font-size'),
                    min: 14,
                    max: 26,
                    divisions: 6,
                    value: s.fontSize,
                    onChanged: (v) => set(s.copyWith(fontSize: v)),
                  ),
                ),
                Text('A', style: T.title.copyWith(fontSize: 26)),
              ],
            ),
            label('Font'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in ['Original', 'Serif', 'Sans', 'Dyslexic-friendly'])
                  Pill(
                    f,
                    selected: s.family == f,
                    keyName: 'font-$f',
                    onTap: () => set(s.copyWith(family: f)),
                  ),
              ],
            ),
            label('Theme'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final th in ReaderTheme.values)
                  GestureDetector(
                    key: ValueKey('theme-${th.name}'),
                    onTap: () => set(s.copyWith(theme: th)),
                    child: Column(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ReaderSettings(theme: th).background,
                            border: Border.all(color: s.theme == th ? Pal.accentFill : Pal.border, width: s.theme == th ? 3 : 1),
                          ),
                          child: s.theme == th ? Icon(Icons.check_rounded, color: th == ReaderTheme.night ? Colors.white : Pal.accentFill) : null,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          th.name[0].toUpperCase() + th.name.substring(1),
                          style: T.caption.copyWith(color: s.theme == th ? Pal.text : Pal.text2, fontWeight: s.theme == th ? FontWeight.w800 : FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      label('Spacing'),
                      seg<double>(
                        [(1.35, Icons.density_small_rounded), (1.6, Icons.density_medium_rounded), (1.9, Icons.density_large_rounded)],
                        s.lineHeight,
                        (v) => set(s.copyWith(lineHeight: v)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      label('Margins'),
                      seg<double>(
                        [(18, Icons.format_align_justify_rounded), (28, Icons.format_indent_increase_rounded), (40, Icons.view_column_rounded)],
                        s.margin,
                        (v) => set(s.copyWith(margin: v)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: s.scroll,
              onChanged: (v) => set(s.copyWith(scroll: v)),
              title: Text('Scroll instead of pages', style: T.label),
              subtitle: Text('Continuous vertical scrolling', style: T.caption),
            ),
          ],
        ),
      ),
    );
  }
}

class ContentsScreen extends ConsumerStatefulWidget {
  const ContentsScreen({super.key, required this.id, required this.tab});
  final String id, tab;
  @override
  ConsumerState<ContentsScreen> createState() => _ContentsState();
}

class _ContentsState extends ConsumerState<ContentsScreen> {
  late String _tab = widget.tab;

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(catalogProvider).value;
    if (c == null) return const Scaffold();
    final t = c.title(widget.id);
    final book = ref.watch(epubProvider(t.epub!)).value;
    final marks = ref.watch(bookmarksProvider).where((b) => b.bookId == t.id).toList();
    final p = ref.watch(progressProvider)[t.id];
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 20, 12),
              child: Row(
                children: [
                  RoundIcon(Icons.close_rounded, keyName: 'close', tooltip: 'Close', onTap: () => context.pop()),
                  const SizedBox(width: 14),
                  BookCover(t, width: 44, radius: 6),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.title, style: T.title.copyWith(fontSize: 18)),
                        Text('${((p?.fraction ?? 0) * 100).round()}% · Chapter ${(p?.chapter ?? 0) + 1}', style: T.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Pal.border)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  for (final (k, l) in [('contents', 'Contents'), ('bookmarks', 'Bookmarks'), ('highlights', 'Highlights ${_highlights.length}')])
                    InkWell(
                      key: ValueKey('tab-$k'),
                      onTap: () => setState(() => _tab = k),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: _tab == k ? Pal.accentFill : Colors.transparent, width: 3)),
                        ),
                        child: Text(l, style: T.label.copyWith(color: _tab == k ? Pal.accentFill : Pal.text2)),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: switch (_tab) {
                'contents' => ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    for (final (i, ch) in (book?.chapters ?? const <EpubChapter>[]).indexed)
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                        leading: Text('${i + 1}'.padLeft(2, '0'), style: T.label.copyWith(color: i == p?.chapter ? Pal.accentFill : Pal.text2)),
                        title: Text(
                          ch.title,
                          style: T.body.copyWith(
                            fontWeight: i == p?.chapter ? FontWeight.w800 : FontWeight.w400,
                            color: i == p?.chapter ? Pal.accentFill : Pal.text,
                          ),
                        ),
                        trailing: i == p?.chapter ? const TypeLabel('Reading') : null,
                        onTap: () => context.pushReplacement('/read/${t.id}?ch=$i'),
                      ),
                  ],
                ),
                'highlights' => ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    for (final h in _highlights)
                      CardBox(
                        child: Container(
                          padding: const EdgeInsets.only(left: 12),
                          decoration: const BoxDecoration(
                            border: Border(left: BorderSide(color: Pal.support, width: 4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ch 7 · The Long Paddock', style: T.label),
                              const SizedBox(height: 6),
                              Text(
                                h,
                                style: T.body.copyWith(fontStyle: FontStyle.italic, color: Pal.text2, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                _ => ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  children: [
                    Text('${marks.length} bookmarks · swipe left to delete', style: T.caption),
                    const SizedBox(height: 12),
                    for (final b in marks)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Dismissible(
                          key: ValueKey('bm-${b.chapter}-${b.page}'),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => ref.read(bookmarksProvider.notifier).remove(b),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            decoration: BoxDecoration(color: Pal.danger, borderRadius: BorderRadius.circular(Pal.cardRadius)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.delete_outline_rounded, color: Colors.white),
                                const SizedBox(width: 6),
                                Text('Delete', style: T.label.copyWith(color: Colors.white)),
                              ],
                            ),
                          ),
                          child: CardBox(
                            onTap: () => context.pushReplacement('/read/${t.id}?ch=${b.chapter}'),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.bookmark_rounded, color: Pal.accent, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text('Ch ${b.chapter + 1} · ${b.chapterTitle} · p.${b.page}', style: T.label)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(color: Pal.surfaceAlt, borderRadius: BorderRadius.circular(99)),
                                      child: Text(b.when, style: T.caption.copyWith(fontSize: 12, color: Pal.text2)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.only(left: 10),
                                  decoration: const BoxDecoration(
                                    border: Border(left: BorderSide(color: Pal.border, width: 2)),
                                  ),
                                  child: Text(
                                    '"${b.snippet}"',
                                    style: T.body.copyWith(fontSize: 14, fontStyle: FontStyle.italic, color: Pal.text2),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}
