import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});
  @override
  ConsumerState<LibraryScreen> createState() => _LibraryState();
}

class _LibraryState extends ConsumerState<LibraryScreen> {
  String _seg = 'All';

  @override
  Widget build(BuildContext context) {
    final c = ref.watch(catalogProvider).value;
    final progress = ref.watch(progressProvider);
    final downloads = ref.watch(downloadsProvider).where((d) => d.done).map((d) => d.bookId).toSet();
    final premium = ref.watch(premiumProvider);
    if (c == null) return const SizedBox();
    final shelf = [
      for (final p in progress.values)
        if (_seg == 'All' || (_seg == 'Ebooks' && c.title(p.bookId).isEbook) || (_seg == 'Audiobooks' && c.title(p.bookId).isAudio)) (c.title(p.bookId), p),
    ];
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Library', style: T.display),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      for (final s in ['All', 'Ebooks', 'Audiobooks']) ...[
                        Pill(s, selected: _seg == s, keyName: 'seg-$s', onTap: () => setState(() => _seg = s)),
                        const SizedBox(width: 8),
                      ],
                      const Spacer(),
                      const Icon(Icons.swap_vert_rounded, size: 18, color: Pal.text2),
                      Text('Recent', style: T.caption.copyWith(color: Pal.text)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (progress.isEmpty)
            const SliverToBoxAdapter(child: _EmptyLibrary())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              sliver: SliverGrid.builder(
                itemCount: shelf.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 16,
                  childAspectRatio: .52,
                ),
                itemBuilder: (_, i) =>
                    _ShelfItem(t: shelf[i].$1, p: shelf[i].$2, downloaded: downloads.contains(shelf[i].$1.id), locked: shelf[i].$1.premium && !premium),
              ),
            ),
        ],
      ),
    );
  }
}

class _ShelfItem extends StatelessWidget {
  const _ShelfItem({required this.t, required this.p, required this.downloaded, required this.locked});
  final Book t;
  final Progress p;
  final bool downloaded, locked;
  @override
  Widget build(BuildContext context) => GestureDetector(
    key: ValueKey('shelf-${t.id}'),
    onTap: () => context.push('/book/${t.id}'),
    child: LayoutBuilder(
      builder: (_, box) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookCover(
            t,
            width: box.maxWidth,
            locked: locked,
            badge: downloaded
                ? Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.download_done_rounded, size: 16, color: Pal.success),
                  )
                : (!t.isEbook ? const Icon(Icons.headphones_rounded, color: Colors.white) : null),
          ),
          const SizedBox(height: 10),
          Text(t.title, style: T.label, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(t.author, style: T.caption, maxLines: 1),
          const SizedBox(height: 8),
          if (p.fraction >= 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Pal.successTint, borderRadius: BorderRadius.circular(99)),
              child: Text(
                'Finished',
                style: T.caption.copyWith(fontSize: 12, color: Pal.success, fontWeight: FontWeight.w800),
              ),
            )
          else if (p.fraction == 0)
            Text(
              locked ? 'Premium title' : 'New',
              style: T.caption.copyWith(color: Pal.accentFill, fontWeight: FontWeight.w700),
            )
          else
            Row(
              children: [
                Expanded(child: Bar(p.fraction)),
                const SizedBox(width: 8),
                Text('${(p.fraction * 100).round()}%', style: T.caption.copyWith(fontSize: 12)),
              ],
            ),
        ],
      ),
    ),
  );
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
    child: Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset('assets/images/empty-reading-nook.jpg', height: 240, width: double.infinity, fit: BoxFit.cover),
        ),
        const SizedBox(height: 22),
        Text(
          'Nothing on your shelf yet',
          style: T.title.copyWith(fontFamily: Pal.display, fontSize: 24),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Books and audiobooks you start or save will live here, ready offline too.',
          style: T.body.copyWith(color: Pal.text2),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        PrimaryButton('Explore new releases', onTap: () => context.go('/today')),
        TextButton(
          onPressed: () => context.go('/search?q=free'),
          child: Text('See free titles', style: T.label.copyWith(color: Pal.accentFill)),
        ),
      ],
    ),
  );
}
