import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/providers.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

class FavouritesScreen extends ConsumerStatefulWidget {
  const FavouritesScreen({super.key});
  @override
  ConsumerState<FavouritesScreen> createState() => _FavState();
}

class _FavState extends ConsumerState<FavouritesScreen> {
  String _f = 'all';

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(catalogProvider).value;
    final favs = ref.watch(favouritesProvider);
    if (c == null) return const Scaffold();
    final items = <(String, String, String, String, String, String)>[]; // key, type, title, meta, image, route
    for (final k in favs) {
      final [kind, id] = k.split(':');
      switch (kind) {
        case 'title':
          final t = c.title(id);
          items.add((k, t.isEbook ? 'EBOOK' : 'AUDIOBOOK', t.title, t.isEbook ? t.author : '${t.author} · ${t.audioLength}', t.cover, '/book/$id'));
        case 'daily':
          final d = c.piece(id);
          items.add((k, 'DAILY', d.title, '${d.author} · ${d.minutes} min', d.hero, '/article/$id'));
        case 'ref':
          final r = c.ref(id);
          items.add((k, 'REFERENCE', r.title, r.summary, r.photo, '/reference/$id'));
      }
    }
    final counts = {
      'books': items.where((i) => i.$2 == 'EBOOK' || i.$2 == 'AUDIOBOOK').length,
      'daily': items.where((i) => i.$2 == 'DAILY').length,
      'ref': items.where((i) => i.$2 == 'REFERENCE').length,
    };
    final shown = items.where(
      (i) => switch (_f) {
        'books' => i.$2 == 'EBOOK' || i.$2 == 'AUDIOBOOK',
        'daily' => i.$2 == 'DAILY',
        'ref' => i.$2 == 'REFERENCE',
        _ => true,
      },
    );
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const TopBar(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Favourites', style: T.display),
                  Text('${items.length} saved', style: T.caption),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    children: [
                      Pill('All', selected: _f == 'all', onTap: () => setState(() => _f = 'all')),
                      Pill('Books ${counts['books']}', selected: _f == 'books', onTap: () => setState(() => _f = 'books')),
                      Pill('Daily ${counts['daily']}', selected: _f == 'daily', onTap: () => setState(() => _f = 'daily')),
                      Pill('Reference ${counts['ref']}', selected: _f == 'ref', onTap: () => setState(() => _f = 'ref')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  for (final i in shown)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CardBox(
                        padding: const EdgeInsets.all(12),
                        onTap: () => context.push(i.$6),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset('assets/images/${i.$5}.jpg', width: 60, height: 78, fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    i.$2,
                                    style: T.caption.copyWith(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1, color: Pal.accentFill),
                                  ),
                                  Text(i.$3, style: T.label),
                                  Text(i.$4, style: T.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Remove favourite',
                              onPressed: () => ref.read(favouritesProvider.notifier).toggle(i.$1),
                              icon: const Icon(Icons.favorite_rounded, color: Pal.accent),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
