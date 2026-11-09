import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/providers.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    body: Column(
      children: [
        Expanded(
          flex: 11,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/images/hero-welcome.jpg', fit: BoxFit.cover),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00FCF4F6), Pal.bg], stops: [.7, 1]),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 10,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset('assets/images/icon-transparent.png', width: 30, height: 30),
                      const SizedBox(width: 6),
                      Text(
                        'Inkwell',
                        style: T.title.copyWith(fontFamily: Pal.display, color: Pal.accentFill),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Read it. Hear it.\nEvery day.', style: T.display),
                  const SizedBox(height: 10),
                  Text('Ebooks, audiobooks and a fresh daily read from Australian authors.', style: T.body.copyWith(color: Pal.text2)),
                  const Spacer(),
                  PrimaryButton(
                    'Create free account',
                    keyName: 'create-account',
                    onTap: () {
                      ref.read(sessionProvider.notifier).createAccount();
                      context.go('/today');
                    },
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton('I already have an account', keyName: 'have-account', onTap: () => context.push('/sign-in')),
                  const SizedBox(height: 12),
                  Center(child: Text('Free forever, upgrade anytime', style: T.caption)),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});
  @override
  ConsumerState<SignInScreen> createState() => _SignInState();
}

class _SignInState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController(text: 'mia.harper@email.com.au');
  final _pass = TextEditingController(text: 'paddock-1890');
  bool _hide = true;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          Row(
            children: [RoundIcon(Icons.arrow_back_ios_new_rounded, tooltip: 'Back', onTap: () => context.pop())],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset('assets/images/hero-sign-in.jpg', height: 150, fit: BoxFit.cover),
          ),
          const SizedBox(height: 24),
          const Text('Welcome back', style: T.display),
          const SizedBox(height: 6),
          Text('Sign in to sync your bookmarks, favourites and membership.', style: T.body.copyWith(color: Pal.text2)),
          const SizedBox(height: 24),
          TextField(
            controller: _email,
            style: T.body,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.mail_outline_rounded, color: Pal.text2),
              suffixIcon: Icon(Icons.check_circle_rounded, color: Pal.success),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _pass,
            obscureText: _hide,
            style: T.body,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Pal.text2),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _hide = !_hide),
                icon: Icon(_hide ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Pal.text2),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text('Forgot password?', style: T.label.copyWith(color: Pal.accentFill)),
            ),
          ),
          const SizedBox(height: 4),
          PrimaryButton(
            'Sign in',
            keyName: 'sign-in',
            onTap: () {
              ref.read(sessionProvider.notifier).signIn();
              context.go('/today');
            },
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(child: Divider(color: Pal.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('or', style: T.caption),
              ),
              const Expanded(child: Divider(color: Pal.border)),
            ],
          ),
          const SizedBox(height: 18),
          const SecondaryButton('Continue with Apple', icon: Icons.apple),
          const SizedBox(height: 12),
          const SecondaryButton('Continue with Google', icon: Icons.g_mobiledata_rounded),
          const SizedBox(height: 20),
          Center(
            child: Text.rich(
              TextSpan(
                style: T.caption,
                children: [
                  const TextSpan(text: 'New here? '),
                  TextSpan(
                    text: 'Create an account',
                    style: T.caption.copyWith(color: Pal.accentFill, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
