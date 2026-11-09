import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/providers.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

/// Paywall. Production wires the two plans to App Store / Google Play
/// subscriptions through RevenueCat; the POC flips a local entitlement.
class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});
  @override
  ConsumerState<PremiumScreen> createState() => _PremiumState();
}

class _PremiumState extends ConsumerState<PremiumScreen> {
  bool _annual = true;

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(premiumProvider);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: RoundIcon(Icons.close_rounded, keyName: 'close', tooltip: 'Close', onTap: () => context.pop()),
            ),
            const SizedBox(height: 8),
            Container(
              height: 196,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), boxShadow: Pal.shadow),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/images/hero-premium.jpg', fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00AB4766), Color(0xF2AB4766), Color(0xFFA14862)],
                        stops: [.25, .7, 1],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const PremiumBadge(label: 'PREMIUM'),
                        const SizedBox(height: 6),
                        Text('Inkwell Premium', style: T.display.copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'The complete Australian catalogue, in print and audio.',
                style: T.body.copyWith(color: Pal.text2, fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 14),
            CardBox(
              child: Column(
                children: [
                  for (final b in ['Every ebook and audiobook, unlimited', 'Offline downloads', 'Full reference library', 'Ad-free daily editions'])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: const BoxDecoration(color: Pal.successTint, shape: BoxShape.circle),
                            child: const Icon(Icons.check_rounded, size: 17, color: Pal.success),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(b, style: T.label)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _Plan(
              selected: _annual,
              title: 'Annual',
              price: r'A$89.99 / year',
              sub: r'A$7.50 / month, billed yearly',
              badge: 'Best value · Save 37%',
              onTap: () => setState(() => _annual = true),
            ),
            const SizedBox(height: 10),
            _Plan(selected: !_annual, title: 'Monthly', price: r'A$11.99 / month', sub: 'Cancel anytime', onTap: () => setState(() => _annual = false)),
            const SizedBox(height: 18),
            PrimaryButton(
              isPremium ? 'You are Premium' : 'Start 7-day free trial',
              keyName: 'start-trial',
              onTap: () {
                ref.read(premiumProvider.notifier).upgrade();
                context.pop();
              },
            ),
            const SizedBox(height: 10),
            Center(child: Text('Cancel anytime. Renews automatically.', style: T.caption.copyWith(fontSize: 14))),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final (i, l) in ['Restore purchases', 'Terms', 'Privacy'].indexed) ...[
                  if (i > 0) Text(' · ', style: T.caption),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
                    child: Text(
                      l,
                      style: T.caption.copyWith(color: Pal.accentFill, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Plan extends StatelessWidget {
  const _Plan({required this.selected, required this.title, required this.price, required this.sub, this.badge, required this.onTap});
  final bool selected;
  final String title, price, sub;
  final String? badge;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    key: ValueKey('plan-$title'),
    onTap: onTap,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFF5F8) : Colors.white,
            borderRadius: BorderRadius.circular(Pal.cardRadius),
            border: Border.all(color: selected ? Pal.accentFill : Pal.border, width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              Icon(selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, color: selected ? Pal.accentFill : Pal.borderStrong),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: T.label.copyWith(fontSize: 16)),
                    Text(sub, style: T.caption),
                  ],
                ),
              ),
              Text(price, style: T.label.copyWith(color: selected ? Pal.accentFill : Pal.text)),
            ],
          ),
        ),
        if (badge != null) Positioned(right: 14, top: -11, child: PremiumBadge(small: true, label: badge!)),
      ],
    ),
  );
}
