import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/audio_controller.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(catalogProvider).value;
    if (c == null) return const Scaffold();
    final t = c.title(id);
    final open = ref.watch(canOpenProvider(t));
    final fav = ref.watch(favouritesProvider).contains('title:$id');
    final more = c.titles.where((x) => x.author == t.author && x.id != t.id).toList();

    Future<void> listen() async {
      if (!open) {
        context.push('/premium');
        return;
      }
      await ref.read(audioProvider.notifier).open(t);
      if (context.mounted) context.push('/player');
    }

    void read() => open ? context.push('/read/${t.id}') : context.push('/premium');

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: 360,
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFEDCE6), Color(0xFFEFF8DF)]),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                TopBar(actions: const [RoundIcon(Icons.ios_share_rounded, tooltip: 'Share')]),
                const SizedBox(height: 8),
                Center(child: BookCover(t, width: 176, radius: 12, locked: t.premium && !open)),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.title, style: T.display, textAlign: TextAlign.center),
                      Text(t.author, style: T.body.copyWith(color: Pal.text2)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 18, color: Color(0xFFA75906)),
                          const SizedBox(width: 4),
                          Text('${t.rating}', style: T.label),
                          Text('  (${t.ratings})', style: T.caption),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final g in t.genres) Pill(g),
                          if (t.pages != null) Pill('${t.pages} pages', icon: Icons.menu_book_rounded),
                          if (t.isAudio) Pill('${t.audioLength} audio', icon: Icons.headphones_rounded),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          if (t.isEbook)
                            Expanded(
                              child: PrimaryButton(
                                open ? 'Read' : 'Unlock',
                                icon: open ? Icons.menu_book_rounded : Icons.lock_open_rounded,
                                keyName: 'read',
                                onTap: read,
                              ),
                            ),
                          if (t.isEbook && t.isAudio) const SizedBox(width: 12),
                          if (t.isAudio)
                            Expanded(
                              child: (t.isEbook ? SecondaryButton.new : PrimaryButton.new)(
                                'Listen',
                                icon: Icons.headphones_rounded,
                                keyName: 'listen',
                                onTap: listen,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _Action(
                            fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            'Favourite',
                            active: fav,
                            onTap: () => ref.read(favouritesProvider.notifier).toggle('title:$id'),
                          ),
                          const _Action(Icons.download_rounded, 'Download'),
                          const _Action(Icons.bookmark_border_rounded, 'Save'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(t.blurb, style: T.body.copyWith(color: Pal.text2, height: 1.6)),
                      if (t.narrator != null) ...[
                        const SizedBox(height: 18),
                        CardBox(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: t.narratorPhoto == null ? null : AssetImage('assets/images/${t.narratorPhoto}.jpg'),
                                backgroundColor: Pal.accentTint,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Narrated by', style: T.caption),
                                  Text(t.narrator!, style: T.label),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (more.isNotEmpty) ...[
                  SectionHeader('More from ${t.author}'),
                  SizedBox(
                    height: 170,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: more.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 14),
                      itemBuilder: (_, i) => GestureDetector(
                        onTap: () => context.push('/book/${more[i].id}'),
                        child: BookCover(more[i], width: 112, locked: more[i].premium),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action(this.icon, this.label, {this.active = false, this.onTap});
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: onTap ?? () {},
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Icon(icon, color: active ? Pal.accent : Pal.text2),
          const SizedBox(height: 4),
          Text(label, style: T.caption.copyWith(fontSize: 12)),
        ],
      ),
    ),
  );
}
