import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/providers.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(sessionProvider);
    final premium = ref.watch(premiumProvider);
    final favs = ref.watch(favouritesProvider).length;
    final marks = ref.watch(bookmarksProvider).length;
    final dl = ref.watch(downloadsProvider);
    final finished = ref.watch(progressProvider).values.where((p) => p.fraction >= 1).length;
    final books = s.firstRun ? finished : 11 + finished;
    final mb = dl.fold<double>(0, (a, d) => a + d.mb * d.progress);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Row(
            children: [
              const Text('Profile', style: T.display),
              const Spacer(),
              const RoundIcon(Icons.settings_outlined, tooltip: 'Settings'),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: Pal.shadow),
                  child: const CircleAvatar(radius: 44, backgroundImage: AssetImage('assets/images/avatar-mia.jpg')),
                ),
                const SizedBox(height: 10),
                Text('Mia Harper', style: T.title.copyWith(fontFamily: Pal.display, fontSize: 24)),
                Text(s.email, style: T.caption),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    premium ? const PremiumBadge(label: 'Premium member') : const TypeLabel('Free plan'),
                    if (!premium)
                      TextButton.icon(
                        key: const ValueKey('upgrade'),
                        onPressed: () => context.push('/premium'),
                        icon: const Icon(Icons.workspace_premium_rounded, size: 18, color: Pal.accentFill),
                        label: Text('Upgrade', style: T.label.copyWith(color: Pal.accentFill)),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Pal.cardRadius),
              boxShadow: Pal.shadow,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFFFF), Color(0xFFFFF0F4), Color(0xFFF5FBEA)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('$books', style: T.display.copyWith(fontSize: 48, color: Pal.accentFill, height: 1)),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('books this year', style: T.body.copyWith(color: Pal.text2)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Bar(books / 15, height: 6, color: Pal.accent),
                const SizedBox(height: 6),
                Text('Goal: 15 books', style: T.caption.copyWith(color: Pal.text2)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: Pal.accentFill, size: 20),
                    const SizedBox(width: 6),
                    Text(s.firstRun ? 'Start a streak today' : '9 day reading streak', style: T.label),
                    const Spacer(),
                    const Icon(Icons.headphones_rounded, color: Pal.accentFill, size: 20),
                    const SizedBox(width: 6),
                    Text(s.firstRun ? '0 h listened' : '48 h listened', style: T.label),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CardBox(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _Row(Icons.favorite_border_rounded, 'Favourites', trailing: '$favs saved', keyName: 'row-favourites', onTap: () => context.push('/favourites')),
                _Row(Icons.bookmark_border_rounded, 'Bookmarks and highlights', trailing: '$marks', onTap: () => context.push('/read/salt-road/contents')),
                _Row(
                  Icons.download_done_rounded,
                  'Downloads',
                  trailing: '${dl.length} · ${(mb / 1000).toStringAsFixed(1)} GB',
                  keyName: 'row-downloads',
                  onTap: () => context.push('/downloads'),
                ),
                const _Row(Icons.text_fields_rounded, 'Reading preferences', trailing: 'Paper · Original'),
                const _Row(Icons.notifications_none_rounded, 'Notifications', trailing: 'Daily 7 am'),
                _Row(Icons.workspace_premium_outlined, 'Membership', trailing: premium ? 'Premium' : 'Free plan', onTap: () => context.push('/premium')),
                const _Row(Icons.help_outline_rounded, 'Help and support', last: true),
              ],
            ),
          ),
          const SizedBox(height: 14),
          CardBox(
            padding: EdgeInsets.zero,
            onTap: () {
              ref.read(sessionProvider.notifier).signOut();
              context.go('/');
            },
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: Pal.danger),
              title: Text('Sign out', style: T.label.copyWith(color: Pal.danger)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.icon, this.label, {this.trailing, this.onTap, this.last = false, this.keyName});
  final IconData icon;
  final String label;
  final String? trailing, keyName;
  final VoidCallback? onTap;
  final bool last;
  @override
  Widget build(BuildContext context) => InkWell(
    key: keyName == null ? null : ValueKey(keyName!),
    onTap: onTap ?? () {},
    child: Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: Pal.border)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Pal.accentFill, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: T.label.copyWith(fontWeight: FontWeight.w600)),
          ),
          if (trailing != null) Text(trailing!, style: T.caption),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: Pal.text2),
        ],
      ),
    ),
  );
}
