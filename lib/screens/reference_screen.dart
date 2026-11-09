import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/providers.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

class ReferenceScreen extends ConsumerWidget {
  const ReferenceScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(catalogProvider).value;
    if (c == null) return const Scaffold();
    final r = c.ref(id);
    final fav = ref.watch(favouritesProvider).contains('ref:$id');
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            TopBar(
              actions: [
                RoundIcon(
                  fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: fav ? Pal.accent : Pal.text,
                  tooltip: 'Favourite',
                  onTap: () => ref.read(favouritesProvider.notifier).toggle('ref:$id'),
                ),
                const RoundIcon(Icons.ios_share_rounded, tooltip: 'Share'),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.path.join('  ›  '), style: T.caption),
                  const SizedBox(height: 4),
                  Text(r.title, style: T.display),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Pal.cardRadius),
                    child: Image.asset('assets/images/${r.photo}.jpg', height: 200, width: double.infinity, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 16),
                  CardBox(
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          for (final (i, f) in r.facts.indexed) ...[
                            if (i > 0) const VerticalDivider(color: Pal.border, width: 20),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    f.$1,
                                    style: T.title.copyWith(color: Pal.accentFill, fontFamily: Pal.display, fontSize: f.$1.length > 6 ? 16 : 24),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(f.$2, style: T.caption, textAlign: TextAlign.center),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  for (final p in r.body)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(p, style: T.body.copyWith(height: 1.65)),
                    ),
                ],
              ),
            ),
            const SectionHeader('Related titles'),
            SizedBox(
              height: 210,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: r.related.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (_, i) {
                  final t = c.title(r.related[i]);
                  return GestureDetector(
                    onTap: () => context.push('/book/${t.id}'),
                    child: SizedBox(
                      width: 104,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BookCover(t, width: 104),
                          const SizedBox(height: 6),
                          Text(t.title, style: T.label.copyWith(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('See also', style: T.title),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final s in r.seeAlso)
                        Pill(
                          s,
                          icon: Icons.arrow_forward_rounded,
                          onTap: () {
                            final hit = c.reference.where((x) => x.title == s).firstOrNull;
                            if (hit != null) context.push('/reference/${hit.id}');
                          },
                        ),
                    ],
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
