import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../state/audio_controller.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    final session = ref.watch(sessionProvider);
    final progress = ref.watch(progressProvider);
    return catalog.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (c) {
        final piece = c.daily.first;
        final continuing = [
          for (final id in ['salt-road', 'harbour-lights'])
            if (progress.containsKey(id)) c.title(id),
        ];
        return SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Monday 9 November', style: T.caption),
                          Text('Good morning, ${session.name}', style: T.display.copyWith(fontSize: 28)),
                        ],
                      ),
                    ),
                    const CircleAvatar(radius: 24, backgroundImage: AssetImage('assets/images/avatar-mia.jpg')),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: DailyHero(piece: piece),
              ),
              if (continuing.isEmpty)
                const _EmptyShelf()
              else ...[
                SectionHeader('Continue', trailing: '${continuing.length} in progress'),
                SizedBox(
                  height: 168,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: continuing.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => _ContinueCard(t: continuing[i], p: progress[continuing[i].id]!),
                  ),
                ),
              ],
              const SectionHeader('New this week', trailing: 'See all'),
              SizedBox(
                height: 238,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (_, i) {
                    final t = c.titles[[0, 1, 2, 5, 9][i]];
                    return GestureDetector(
                      key: ValueKey('new-${t.id}'),
                      onTap: () => context.push('/book/${t.id}'),
                      child: SizedBox(
                        width: 120,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BookCover(t, width: 120, locked: t.premium, badge: t.isAudio && !t.isEbook ? const _AudioDot() : null),
                            const SizedBox(height: 8),
                            Text(t.title, style: T.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(t.author, style: T.caption, maxLines: 1),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AudioDot extends StatelessWidget {
  const _AudioDot();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(5),
    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
    child: const Icon(Icons.headphones_rounded, size: 14, color: Pal.accentFill),
  );
}

class DailyHero extends StatelessWidget {
  const DailyHero({super.key, required this.piece});
  final DailyPiece piece;
  @override
  Widget build(BuildContext context) => GestureDetector(
    key: const ValueKey('daily-hero'),
    onTap: () => context.push('/article/${piece.id}'),
    child: Container(
      height: 236,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Pal.cardRadius), boxShadow: Pal.shadow),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/${piece.hero}.jpg', fit: BoxFit.cover),
          const DecoratedBox(decoration: BoxDecoration(gradient: Pal.heroScrim)),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0x661F0C11), borderRadius: BorderRadius.circular(99)),
                  child: Text(
                    piece.kicker,
                    style: T.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  piece.title,
                  style: T.title.copyWith(color: Colors.white, fontFamily: Pal.display, fontSize: 24, height: 1.1),
                ),
                const SizedBox(height: 4),
                Text('${piece.author} · ${piece.minutes} min read', style: T.caption.copyWith(color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ContinueCard extends ConsumerWidget {
  const _ContinueCard({required this.t, required this.p});
  final Book t;
  final Progress p;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = !t.isEbook;
    return SizedBox(
      width: 236,
      child: CardBox(
        padding: const EdgeInsets.all(14),
        onTap: () async {
          if (audio) {
            await ref.read(audioProvider.notifier).open(t);
            if (context.mounted) context.push('/player');
          } else {
            context.push('/read/${t.id}');
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookCover(t, width: 58, radius: 8),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TypeLabel(audio ? 'Listen' : 'Read', icon: audio ? Icons.headphones_rounded : Icons.menu_book_rounded),
                      const SizedBox(height: 6),
                      Text(t.title, style: T.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(t.author, style: T.caption, maxLines: 1),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Bar(p.fraction),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(audio ? 'Ch 12' : 'Chapter ${p.chapter + 1}', style: T.caption),
                const Spacer(),
                Text(audio ? (p.audioLeft ?? '') : '${(p.fraction * 100).round()}%', style: T.caption.copyWith(color: Pal.text)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyShelf extends StatelessWidget {
  const _EmptyShelf();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
    child: CardBox(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset('assets/images/empty-bookshelf.jpg', height: 150, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 14),
          Text('Your shelf is waiting', style: T.title.copyWith(fontFamily: Pal.display, fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            'Start a book or an audiobook and it will appear here so you can pick up where you left off.',
            style: T.body.copyWith(color: Pal.text2, fontSize: 15),
          ),
          const SizedBox(height: 14),
          PrimaryButton('Browse the library', keyName: 'browse-library', onTap: () => context.go('/library')),
          Center(
            child: TextButton(
              onPressed: () => context.push('/book/harbour-lights'),
              child: Text('Try a free audiobook', style: T.label.copyWith(color: Pal.accentFill)),
            ),
          ),
        ],
      ),
    ),
  );
}
