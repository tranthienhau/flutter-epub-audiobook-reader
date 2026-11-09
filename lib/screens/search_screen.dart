import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery});
  final String? initialQuery;
  @override
  ConsumerState<SearchScreen> createState() => _SearchState();
}

class _SearchState extends ConsumerState<SearchScreen> {
  late final _q = TextEditingController(text: widget.initialQuery ?? 'gold rush');
  String _filter = 'all';
  final _recent = ['Hobart', 'Eleanor Marsh', 'bush poetry'];

  void _open(SearchHit h) => switch (h.kind) {
    'reference' => context.push('/reference/${h.id}'),
    'daily' => context.push('/article/${h.id}'),
    _ => context.push('/book/${h.id}'),
  };

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(catalogProvider).value;
    if (c == null) return const SizedBox();
    final hits = ref.read(cmsProvider).search(c, _q.text, filter: _filter);
    final top = hits.where((h) => h.kind == 'reference').firstOrNull;
    final rest = hits.where((h) => h != top).toList();
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          const Text('Search', style: T.display),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('search-field'),
            controller: _q,
            style: T.body,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Books, audiobooks, essays, reference',
              prefixIcon: const Icon(Icons.search_rounded, color: Pal.text2),
              suffixIcon: _q.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () => setState(_q.clear),
                      icon: const Icon(Icons.cancel_rounded, color: Pal.text3),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final (k, l) in [('all', 'All'), ('ebook', 'Ebooks'), ('audiobook', 'Audiobooks'), ('daily', 'Daily'), ('reference', 'Reference')]) ...[
                  Pill(l, selected: _filter == k, keyName: 'filter-$k', onTap: () => setState(() => _filter = k)),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          if (_q.text.isEmpty) ...[
            const SizedBox(height: 22),
            Text('Recent searches', style: T.label.copyWith(color: Pal.text2)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final r in _recent) Pill(r, icon: Icons.history_rounded, onTap: () => setState(() => _q.text = r))],
            ),
          ] else if (hits.isEmpty) ...[
            const SizedBox(height: 40),
            Center(
              child: Text('No matches for "${_q.text}"', style: T.body.copyWith(color: Pal.text2)),
            ),
          ] else ...[
            if (top != null) ...[
              const SizedBox(height: 18),
              CardBox(
                padding: EdgeInsets.zero,
                onTap: () => _open(top),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('assets/images/${top.image}.jpg', height: 150, width: double.infinity, fit: BoxFit.cover),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PremiumBadge(small: true, label: 'Reference'),
                          const SizedBox(height: 8),
                          Text(top.title, style: T.title),
                          Text(top.subtitle, style: T.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            Text('${rest.length} more matches', style: T.label.copyWith(color: Pal.text2)),
            const SizedBox(height: 10),
            for (final h in rest)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CardBox(
                  padding: const EdgeInsets.all(12),
                  onTap: () => _open(h),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset('assets/images/${h.image}.jpg', width: 56, height: 76, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TypeLabel(
                              switch (h.kind) {
                                'ebook' => 'Ebook',
                                'audiobook' => 'Audiobook',
                                'daily' => 'Daily essay',
                                _ => 'Reference',
                              },
                              icon: switch (h.kind) {
                                'audiobook' => Icons.headphones_rounded,
                                'daily' => Icons.wb_sunny_outlined,
                                _ => Icons.menu_book_rounded,
                              },
                            ),
                            const SizedBox(height: 6),
                            Text(h.title, style: T.label),
                            Text(h.subtitle, style: T.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Pal.text2),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
