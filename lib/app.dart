import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'router.dart';
import 'theme/theme.dart';

bool _audioReady = false;

/// One-time platform setup shared by main() and the integration tests.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (_audioReady) return;
  _audioReady = true;
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.tranthienhau.inkwell.playback',
    androidNotificationChannelName: 'Playback',
    androidNotificationOngoing: true,
  );
}

class InkwellApp extends StatelessWidget {
  InkwellApp({super.key, GoRouter? router}) : router = router ?? buildRouter();
  final GoRouter router;

  @override
  Widget build(BuildContext context) => MaterialApp.router(title: 'Inkwell', debugShowCheckedModeBanner: false, theme: buildTheme(), routerConfig: router);
}
