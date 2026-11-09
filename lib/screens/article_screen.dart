import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/audio_controller.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

class ArticleScreen extends ConsumerWidget {
  const ArticleScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(catalogProvider).value;
    if (c == null) return const Scaffold();
    final d = c.piece(id);
    final fav = ref.watch(favouritesProvider).contains('daily:$id');
    final related = d.relatedTitle == null ? null : c.title(d.relatedTitle!);
    final listening = ref.watch(audioProvider.select((s) => s.essayId == id && s.playing));
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 330,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/images/${d.hero}.jpg', fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x401F0C11), Color(0x001F0C11)],
                        stops: [0, .4],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RoundIcon(Icons.arrow_back_ios_new_rounded, keyName: 'back', tooltip: 'Back', onTap: () => context.pop()),
                          const Spacer(),
                          RoundIcon(
                            fav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            color: fav ? Pal.accent : Pal.text,
                            tooltip: 'Save',
                            onTap: () => ref.read(favouritesProvider.notifier).toggle('daily:$id'),
                          ),
                          const SizedBox(width: 10),
                          const RoundIcon(Icons.ios_share_rounded, tooltip: 'Share'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -24, 0),
              decoration: const BoxDecoration(
                color: Pal.bg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${d.kicker} · 9 NOV',
                    style: T.caption.copyWith(color: Pal.accentFill, fontWeight: FontWeight.w800, letterSpacing: 1),
                  ),
                  const SizedBox(height: 6),
                  Text(d.title, style: T.display),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(radius: 22, backgroundImage: AssetImage('assets/images/${d.authorPhoto}.jpg')),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.author, style: T.label),
                          Text('Author and essayist · ${d.minutes} min read', style: T.caption),
                        ],
                      ),
                    ],
                  ),
                  if (d.audio != null) ...[
                    const SizedBox(height: 18),
                    Material(
                      color: Pal.accentTint,
                      borderRadius: BorderRadius.circular(99),
                      child: InkWell(
                        key: const ValueKey('listen-essay'),
                        borderRadius: BorderRadius.circular(99),
                        onTap: () => listening ? ref.read(audioProvider.notifier).toggle() : ref.read(audioProvider.notifier).openEssay(d),
                        child: SizedBox(
                          height: 48,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(listening ? Icons.pause_rounded : Icons.headphones_rounded, color: Pal.accentFill),
                              const SizedBox(width: 8),
                              Text(listening ? 'Listening · tap to pause' : 'Listen to this essay · 0:52', style: T.label.copyWith(color: Pal.accentFill)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  for (final p in d.body)
                    if (p.startsWith('QUOTE:'))
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                        decoration: const BoxDecoration(
                          color: Pal.surfaceAlt,
                          border: Border(left: BorderSide(color: Pal.accent, width: 4)),
                          borderRadius: BorderRadius.horizontal(right: Radius.circular(12)),
                        ),
                        child: Text(
                          p.substring(6),
                          style: T.title.copyWith(fontFamily: Pal.display, color: Pal.accentFill, height: 1.3),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Text(p, style: T.body.copyWith(fontSize: 17, height: 1.65)),
                      ),
                  if (related != null) ...[
                    const SizedBox(height: 12),
                    CardBox(
                      onTap: () => context.push('/book/${related.id}'),
                      child: Row(
                        children: [
                          BookCover(related, width: 56, radius: 8),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('FROM THE AUTHOR', style: T.caption.copyWith(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1)),
                                Text(related.title, style: T.label),
                                Text('${related.genres.first} · ${related.pages} pages', style: T.caption),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Pal.text2),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
