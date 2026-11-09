import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/audio_controller.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';

class TabShell extends ConsumerWidget {
  const TabShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  static const tabs = [
    (Icons.wb_sunny_outlined, Icons.wb_sunny_rounded, 'Today'),
    (Icons.menu_book_outlined, Icons.menu_book_rounded, 'Library'),
    (Icons.search_rounded, Icons.search_rounded, 'Search'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playing = ref.watch(audioProvider.select((s) => s.title != null));
    final firstRun = ref.watch(sessionProvider.select((s) => s.firstRun));
    final showMini = playing && !firstRun && shell.currentIndex != 3;
    return Scaffold(
      body: shell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showMini) const MiniPlayer(),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Pal.border)),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 64,
                child: Row(
                  children: [
                    for (var i = 0; i < tabs.length; i++)
                      Expanded(
                        child: InkWell(
                          key: ValueKey('tab-${tabs[i].$3.toLowerCase()}'),
                          onTap: () => shell.goBranch(i, initialLocation: i == shell.currentIndex),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                                decoration: BoxDecoration(
                                  color: i == shell.currentIndex ? Pal.accentTint : Colors.transparent,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: Icon(
                                  i == shell.currentIndex ? tabs[i].$2 : tabs[i].$1,
                                  size: 24,
                                  color: i == shell.currentIndex ? Pal.accentFill : Pal.text3,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                tabs[i].$3,
                                style: T.caption.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: i == shell.currentIndex ? Pal.accentFill : Pal.text3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(audioProvider);
    final t = s.title!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Material(
        key: const ValueKey('mini-player'),
        color: Colors.white,
        elevation: 0,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/player'),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: Pal.shadow,
              border: Border.all(color: Pal.border),
            ),
            child: Column(
              children: [
                LinearProgressIndicator(value: s.fraction, minHeight: 3, backgroundColor: Pal.surfaceAlt, valueColor: const AlwaysStoppedAnimation(Pal.accent)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(t.coverAsset, width: 44, height: 44, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.title, style: T.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text('Ch ${s.chapter?.n ?? 1} · ${fmt(s.duration - s.position)} left', style: T.caption.copyWith(fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => ref.read(audioProvider.notifier).seekRelative(-15),
                        icon: const Icon(Icons.replay_rounded, color: Pal.text2),
                      ),
                      Material(
                        color: Pal.accentFill,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: ref.read(audioProvider.notifier).toggle,
                          child: SizedBox(width: 44, height: 44, child: Icon(s.playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
