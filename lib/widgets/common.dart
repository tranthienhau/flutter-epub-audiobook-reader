import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../theme/tokens.dart';

class BookCover extends StatelessWidget {
  const BookCover(this.title, {super.key, this.width = 96, this.radius = 10, this.locked = false, this.badge});
  final Book title;
  final double width, radius;
  final bool locked;
  final Widget? badge;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Container(
        width: width,
        height: width * 1.42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: const [BoxShadow(color: Color(0x261F0C11), blurRadius: 14, offset: Offset(0, 6))],
          image: DecorationImage(image: AssetImage(title.coverAsset), fit: BoxFit.cover),
        ),
      ),
      if (locked) const Positioned(left: 6, top: 6, child: PremiumBadge(small: true)),
      if (badge != null) Positioned(right: 6, top: 6, child: badge!),
    ],
  );
}

class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key, this.small = false, this.label = 'Premium'});
  final bool small;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: small ? 8 : 10, vertical: small ? 3 : 4),
    decoration: BoxDecoration(color: Pal.support, borderRadius: BorderRadius.circular(99)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.workspace_premium_rounded, size: small ? 13 : 15, color: Pal.text),
        const SizedBox(width: 4),
        Text(
          label,
          style: T.caption.copyWith(fontSize: small ? 12 : 13, fontWeight: FontWeight.w800, color: Pal.text),
        ),
      ],
    ),
  );
}

class Pill extends StatelessWidget {
  const Pill(this.label, {super.key, this.selected = false, this.icon, this.onTap, this.keyName});
  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback? onTap;
  final String? keyName;

  @override
  Widget build(BuildContext context) => Material(
    key: keyName == null ? null : ValueKey(keyName!),
    color: selected ? Pal.accentFill : Pal.accentTint,
    borderRadius: BorderRadius.circular(99),
    child: InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 36),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 16, color: selected ? Colors.white : Pal.accentFill), const SizedBox(width: 6)],
            Text(
              label,
              style: T.caption.copyWith(fontWeight: FontWeight.w700, color: selected ? Colors.white : Pal.accentFill),
            ),
          ],
        ),
      ),
    ),
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(this.label, {super.key, this.onTap, this.icon, this.keyName});
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final String? keyName;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 52,
    width: double.infinity,
    child: FilledButton(
      key: keyName == null ? null : ValueKey(keyName!),
      onPressed: onTap ?? () {},
      style: FilledButton.styleFrom(
        backgroundColor: Pal.accentFill,
        foregroundColor: Colors.white,
        shape: const StadiumBorder(),
        textStyle: T.label.copyWith(fontSize: 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
          Text(label),
        ],
      ),
    ),
  );
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton(this.label, {super.key, this.onTap, this.icon, this.keyName});
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final String? keyName;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 52,
    width: double.infinity,
    child: OutlinedButton(
      key: keyName == null ? null : ValueKey(keyName!),
      onPressed: onTap ?? () {},
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Pal.text,
        side: const BorderSide(color: Pal.borderStrong, width: 1.5),
        shape: const StadiumBorder(),
        textStyle: T.label.copyWith(fontSize: 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
          Text(label),
        ],
      ),
    ),
  );
}

class RoundIcon extends StatelessWidget {
  const RoundIcon(this.icon, {super.key, this.onTap, this.color = Pal.text, this.bg = Colors.white, this.keyName, this.tooltip});
  final IconData icon;
  final VoidCallback? onTap;
  final Color color, bg;
  final String? keyName, tooltip;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: tooltip,
    child: Material(
      key: keyName == null ? null : ValueKey(keyName!),
      color: bg,
      shape: const CircleBorder(side: BorderSide(color: Pal.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 44, height: 44, child: Icon(icon, size: 22, color: color)),
      ),
    ),
  );
}

class CardBox extends StatelessWidget {
  const CardBox({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.color = Pal.surface});
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(Pal.cardRadius), boxShadow: Pal.shadow),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(Pal.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    ),
  );
}

class Bar extends StatelessWidget {
  const Bar(this.value, {super.key, this.height = 4, this.color = Pal.accent});
  final double value, height;
  final Color color;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(99),
    child: LinearProgressIndicator(value: value, minHeight: height, backgroundColor: Pal.surfaceAlt, valueColor: AlwaysStoppedAnimation(color)),
  );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});
  final String title;
  final String? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
    child: Row(
      children: [
        Expanded(child: Text(title, style: T.title)),
        if (trailing != null)
          Text(
            trailing!,
            style: T.caption.copyWith(color: Pal.accentFill, fontWeight: FontWeight.w700),
          ),
      ],
    ),
  );
}

class TypeLabel extends StatelessWidget {
  const TypeLabel(this.text, {super.key, this.icon});
  final String text;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(color: Pal.accentTint, borderRadius: BorderRadius.circular(99)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 13, color: Pal.accentFill), const SizedBox(width: 4)],
        Text(
          text,
          style: T.caption.copyWith(fontSize: 12, fontWeight: FontWeight.w800, color: Pal.accentFill, letterSpacing: .4),
        ),
      ],
    ),
  );
}

class TopBar extends StatelessWidget {
  const TopBar({super.key, this.title, this.leading = Icons.arrow_back_ios_new_rounded, this.onBack, this.actions = const []});
  final String? title;
  final IconData leading;
  final VoidCallback? onBack;
  final List<Widget> actions;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: Row(
      children: [
        RoundIcon(leading, keyName: 'back', tooltip: 'Back', onTap: onBack ?? () => context.canPop() ? context.pop() : context.go('/today')),
        const SizedBox(width: 12),
        Expanded(
          child: title == null ? const SizedBox() : Text(title!, style: T.title, overflow: TextOverflow.ellipsis),
        ),
        for (final a in actions) ...[const SizedBox(width: 8), a],
      ],
    ),
  );
}
