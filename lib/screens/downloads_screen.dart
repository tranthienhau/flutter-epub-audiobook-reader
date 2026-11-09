import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(catalogProvider).value;
    final dl = ref.watch(downloadsProvider);
    final wifi = ref.watch(wifiOnlyProvider);
    if (c == null) return const Scaffold();
    final audioMb = dl.where((d) => d.kind == 'Audiobook').fold<double>(0, (a, d) => a + d.mb * d.progress);
    final bookMb = dl.where((d) => d.kind == 'Ebook').fold<double>(0, (a, d) => a + d.mb);
    final used = (audioMb + bookMb) / 1000;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const TopBar(title: 'Downloads'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CardBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${used.toStringAsFixed(1)} GB', style: T.display.copyWith(color: Pal.accentFill, fontSize: 36, height: 1)),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text('of 64 GB used', style: T.body.copyWith(color: Pal.text2)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: SizedBox(
                            height: 10,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: (audioMb / 64000 * 1000 * 12).round().clamp(1, 1000),
                                  child: Container(color: Pal.accent),
                                ),
                                Expanded(flex: 8, child: Container(color: Pal.supportStrong)),
                                Expanded(flex: 1000, child: Container(color: Pal.surfaceAlt)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _Legend(Pal.accent, 'Audiobooks ${(audioMb / 1000).toStringAsFixed(2)} GB'),
                            const SizedBox(width: 14),
                            _Legend(Pal.supportStrong, 'Ebooks ${bookMb.round()} MB'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text('On this device', style: T.title),
                  const SizedBox(height: 10),
                  for (final d in dl)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CardBox(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            BookCover(c.title(d.bookId), width: 50, radius: 8),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.title(d.bookId).title, style: T.label),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      TypeLabel(d.kind),
                                      const SizedBox(width: 8),
                                      Text('${d.mb} MB', style: T.caption),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  if (d.done)
                                    Row(
                                      children: [
                                        const Icon(Icons.check_circle_rounded, size: 16, color: Pal.success),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Ready offline',
                                          style: T.caption.copyWith(color: Pal.success, fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    )
                                  else
                                    Row(
                                      children: [
                                        Expanded(child: Bar(d.progress)),
                                        const SizedBox(width: 8),
                                        Text(
                                          d.paused ? 'Paused' : 'Downloading ${(d.progress * 100).round()}%',
                                          style: T.caption.copyWith(color: Pal.accentFill, fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            if (!d.done)
                              IconButton(
                                key: ValueKey('pause-${d.bookId}'),
                                tooltip: d.paused ? 'Resume' : 'Pause',
                                onPressed: () => ref.read(downloadsProvider.notifier).togglePause(d.bookId),
                                icon: Icon(d.paused ? Icons.play_circle_rounded : Icons.pause_circle_rounded, color: Pal.accentFill, size: 30),
                              ),
                            IconButton(
                              tooltip: 'Remove',
                              onPressed: () => ref.read(downloadsProvider.notifier).remove(d.bookId),
                              icon: const Icon(Icons.delete_outline_rounded, color: Pal.text2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  CardBox(
                    padding: EdgeInsets.zero,
                    child: SwitchListTile(
                      value: wifi,
                      onChanged: (_) => ref.read(wifiOnlyProvider.notifier).toggle(),
                      title: Text('Download on Wi-Fi only', style: T.label),
                      subtitle: Text('Saves mobile data on the road', style: T.caption),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton.icon(
                      onPressed: ref.read(downloadsProvider.notifier).clear,
                      icon: const Icon(Icons.delete_sweep_outlined, color: Pal.danger),
                      label: Text('Remove all downloads', style: T.label.copyWith(color: Pal.danger)),
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

class _Legend extends StatelessWidget {
  const _Legend(this.color, this.label);
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(label, style: T.caption),
    ],
  );
}
