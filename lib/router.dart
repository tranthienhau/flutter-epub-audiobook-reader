import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/article_screen.dart';
import 'screens/book_detail_screen.dart';
import 'screens/downloads_screen.dart';
import 'screens/favourites_screen.dart';
import 'screens/library_screen.dart';
import 'screens/onboarding_screens.dart';
import 'screens/player_screen.dart';
import 'screens/premium_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/reader_screen.dart';
import 'screens/reference_screen.dart';
import 'screens/search_screen.dart';
import 'screens/today_screen.dart';
import 'widgets/shell.dart';

GoRouter buildRouter({String initial = '/'}) => GoRouter(
  initialLocation: initial,
  routes: [
    GoRoute(path: '/', builder: (_, _) => const WelcomeScreen()),
    GoRoute(path: '/sign-in', builder: (_, _) => const SignInScreen()),
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => TabShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [GoRoute(path: '/today', builder: (_, _) => const TodayScreen())],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/library', builder: (_, _) => const LibraryScreen())],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (_, s) => SearchScreen(initialQuery: s.uri.queryParameters['q']),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen())],
        ),
      ],
    ),
    GoRoute(
      path: '/article/:id',
      builder: (_, s) => ArticleScreen(id: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/book/:id',
      builder: (_, s) => BookDetailScreen(id: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/read/:id',
      builder: (_, s) =>
          ReaderScreen(id: s.pathParameters['id']!, sheet: s.uri.queryParameters['sheet'], chapter: int.tryParse(s.uri.queryParameters['ch'] ?? '')),
    ),
    GoRoute(
      path: '/read/:id/contents',
      builder: (_, s) => ContentsScreen(id: s.pathParameters['id']!, tab: s.uri.queryParameters['tab'] ?? 'bookmarks'),
    ),
    GoRoute(
      path: '/player',
      pageBuilder: (_, s) => _slideUp(PlayerScreen(sheet: s.uri.queryParameters['sheet'])),
    ),
    GoRoute(
      path: '/reference/:id',
      builder: (_, s) => ReferenceScreen(id: s.pathParameters['id']!),
    ),
    GoRoute(path: '/favourites', builder: (_, _) => const FavouritesScreen()),
    GoRoute(path: '/premium', pageBuilder: (_, _) => _slideUp(const PremiumScreen())),
    GoRoute(path: '/downloads', builder: (_, _) => const DownloadsScreen()),
  ],
);

CustomTransitionPage _slideUp(Widget child) => CustomTransitionPage(
  child: child,
  transitionsBuilder: (_, a, _, c) => SlideTransition(
    position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
    child: c,
  ),
);
