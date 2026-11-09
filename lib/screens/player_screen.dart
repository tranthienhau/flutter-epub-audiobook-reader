import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/audio_controller.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key, this.sheet});
  final String? sheet;
  @override
  ConsumerState<PlayerScreen> createState() => _PlayerState();
}

class _PlayerState extends ConsumerState<PlayerScreen> {
  bool _shown = false;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(audioProvider);
    final a = ref.read(audioProvider.notifier);
    final t = s.title;
    if (t == null) return const Scaffold(body: Center(child: Text('Nothing playing')));
    final fav = ref.watch(favouritesProvider).contains('title:${t.id}');
    final downloaded = ref.watch(downloadsProvider).any((d) => d.bookId == t.id && d.done);
    if (widget.sheet == 'chapters' && !_shown) {
      _shown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => showChapters(context));
    }
    return Scaffold(
      body: Stack(
        children: [
          const Positioned(top: 90, left: -60, right: -60, height: 460, child: _Glow()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      RoundIcon(Icons.keyboard_arrow_down_rounded, keyName: 'collapse', tooltip: 'Close player', onTap: () => context.pop()),
                      Expanded(
                        child: Column(
                          children: [
                            Text('PLAYING FROM LIBRARY', style: T.caption.copyWith(fontSize: 12, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
                            Text(t.title, style: T.label.copyWith(color: Pal.accentFill)),
                          ],
                        ),
                      ),
                      const RoundIcon(Icons.more_horiz_rounded, tooltip: 'More'),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Pal.cardRadius),
                      boxShadow: const [BoxShadow(color: Color(0x331F0C11), blurRadius: 32, offset: Offset(0, 14))],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Pal.cardRadius),
                      child: Image.asset(t.coverAsset, width: 280, height: 280, fit: BoxFit.cover, alignment: const Alignment(0, -.1)),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.title, style: T.display.copyWith(fontSize: 28)),
                            Text('${t.author} · Read by ${t.narrator}', style: T.body.copyWith(color: Pal.text2, fontSize: 15)),
                          ],
                        ),
                      ),
                      RoundIcon(
                        fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: Pal.accentFill,
                        bg: Pal.accentTint,
                        tooltip: 'Favourite',
                        onTap: () => ref.read(favouritesProvider.notifier).toggle('title:${t.id}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TypeLabel('Chapter ${s.chapter?.n} · ${s.chapter?.title}', icon: Icons.graphic_eq_rounded),
                  ),
                  const SizedBox(height: 6),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(thumbColor: Pal.accentFill, trackHeight: 6),
                    child: Slider(key: const ValueKey('scrubber'), value: s.fraction.toDouble(), onChanged: a.seekFraction),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Row(
                      children: [
                        Text(
                          fmt(s.position),
                          style: T.caption.copyWith(color: Pal.text, fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Text('-${fmt(s.duration - s.position)}', style: T.caption),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        tooltip: 'Previous chapter',
                        onPressed: () => a.selectChapter(t.chapters.indexOf(s.chapter ?? t.chapters.first) - 1),
                        icon: const Icon(Icons.skip_previous_rounded, size: 30, color: Pal.text2),
                      ),
                      IconButton(
                        key: const ValueKey('back15'),
                        tooltip: 'Back 15 seconds',
                        onPressed: () => a.seekRelative(-15),
                        icon: const Icon(Icons.replay_rounded, size: 34, color: Pal.text),
                      ),
                      Material(
                        color: Pal.accentFill,
                        shape: const CircleBorder(),
                        elevation: 8,
                        shadowColor: const Color(0x66AB4766),
                        child: InkWell(
                          key: const ValueKey('play-pause'),
                          customBorder: const CircleBorder(),
                          onTap: a.toggle,
                          child: SizedBox(
                            width: 78,
                            height: 78,
                            child: Icon(s.playing ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 40, color: Colors.white),
                          ),
                        ),
                      ),
                      IconButton(
                        key: const ValueKey('fwd30'),
                        tooltip: 'Forward 30 seconds',
                        onPressed: () => a.seekRelative(30),
                        icon: const Icon(Icons.forward_30_rounded, size: 34, color: Pal.text),
                      ),
                      IconButton(
                        tooltip: 'Next chapter',
                        onPressed: () => a.selectChapter(t.chapters.indexOf(s.chapter ?? t.chapters.first) + 1),
                        icon: const Icon(Icons.skip_next_rounded, size: 30, color: Pal.text2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Pal.border),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Util(
                        key: const ValueKey('speed'),
                        top: Text('${s.speed}x', style: T.label.copyWith(color: Pal.accentFill)),
                        label: 'Speed',
                        onTap: a.cycleSpeed,
                      ),
                      _Util(
                        key: const ValueKey('sleep'),
                        top: Icon(
                          s.sleep == SleepTimer.off ? Icons.bedtime_outlined : Icons.bedtime_rounded,
                          color: s.sleep == SleepTimer.off ? Pal.text2 : Pal.accentFill,
                        ),
                        label: switch (s.sleep) {
                          SleepTimer.off => 'Sleep',
                          SleepTimer.endOfChapter => 'End of ch.',
                          SleepTimer.m15 => '15 min',
                          SleepTimer.m30 => '30 min',
                          SleepTimer.m45 => '45 min',
                        },
                        onTap: () => showChapters(context, sleepTab: true),
                      ),
                      _Util(
                        key: const ValueKey('chapters'),
                        top: const Icon(Icons.format_list_bulleted_rounded, color: Pal.text2),
                        label: 'Chapters',
                        onTap: () => showChapters(context),
                      ),
                      const _Util(
                        top: Icon(Icons.bookmark_add_outlined, color: Pal.text2),
                        label: 'Clip',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(downloaded ? Icons.check_circle_rounded : Icons.cloud_queue_rounded, size: 16, color: downloaded ? Pal.success : Pal.text2),
                      const SizedBox(width: 6),
                      Text(downloaded ? 'Downloaded for offline' : 'Streaming', style: T.caption),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow();
  @override
  Widget build(BuildContext context) => const DecoratedBox(
    decoration: BoxDecoration(
      gradient: RadialGradient(colors: [Color(0x55FB7299), Color(0x33B6E36A), Color(0x00FCF4F6)], stops: [0, .45, 1]),
    ),
  );
}

class _Util extends StatelessWidget {
  const _Util({super.key, required this.top, required this.label, this.onTap});
  final Widget top;
  final String label;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: onTap ?? () {},
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        children: [
          SizedBox(height: 26, child: Center(child: top)),
          const SizedBox(height: 4),
          Text(label, style: T.caption.copyWith(fontSize: 12)),
        ],
      ),
    ),
  );
}

Future<void> showChapters(BuildContext context, {bool sleepTab = false}) => showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.white,
  barrierColor: const Color(0x661F0C11),
  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
  builder: (_) => _ChaptersSheet(sleepTab: sleepTab),
);

class _ChaptersSheet extends ConsumerWidget {
  const _ChaptersSheet({required this.sleepTab});
  final bool sleepTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(audioProvider);
    final a = ref.read(audioProvider.notifier);
    final t = s.title!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
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
            const SizedBox(height: 14),
            Text(sleepTab ? 'Sleep timer' : 'Chapters', style: T.title.copyWith(fontFamily: Pal.display, fontSize: 22)),
            const SizedBox(height: 8),
            if (!sleepTab)
              for (final (i, ch) in t.chapters.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: ch == s.chapter ? Pal.accentTint : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: ListTile(
                      key: ValueKey('chapter-${ch.n}'),
                      onTap: () {
                        a.selectChapter(i);
                        Navigator.pop(context);
                      },
                      leading: ch == s.chapter
                          ? const Icon(Icons.graphic_eq_rounded, color: Pal.accentFill)
                          : Text('${ch.n}', style: T.label.copyWith(color: Pal.text2)),
                      title: Text(ch.title, style: T.label.copyWith(color: ch == s.chapter ? Pal.accentFill : Pal.text)),
                      subtitle: ch == s.chapter ? Padding(padding: const EdgeInsets.only(top: 6), child: Bar(s.fraction)) : null,
                      trailing: Text(fmt(Duration(seconds: ch.seconds)), style: T.caption),
                    ),
                  ),
                ),
            if (!sleepTab) const Divider(color: Pal.border, height: 28),
            Row(
              children: [
                const Icon(Icons.bedtime_outlined, color: Pal.text2, size: 20),
                const SizedBox(width: 8),
                Text('Sleep timer', style: T.label),
                const SizedBox(width: 8),
                Text('Stops playback when it ends', style: T.caption),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (v, l) in [
                  (SleepTimer.m15, '15 min'),
                  (SleepTimer.m30, '30 min'),
                  (SleepTimer.m45, '45 min'),
                  (SleepTimer.endOfChapter, 'End of chapter'),
                  (SleepTimer.off, 'Off'),
                ])
                  Pill(l, selected: s.sleep == v, icon: s.sleep == v ? Icons.check_rounded : null, keyName: 'sleep-${v.name}', onTap: () => a.setSleep(v)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
