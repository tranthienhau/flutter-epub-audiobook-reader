import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:inkwell/app.dart';
import 'package:inkwell/router.dart';
import 'package:inkwell/state/audio_controller.dart';
import 'package:inkwell/state/providers.dart';

/// Walks every key screen and captures a real screenshot of the running app.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('screenshot tour', (tester) async {
    await bootstrap();
    await binding.convertFlutterSurfaceToImage();
    var n = 0;
    final c = ProviderContainer();
    final catalog = await c.read(catalogProvider.future);
    c.read(sessionProvider.notifier).signIn();
    await c.read(audioProvider.notifier).open(catalog.title('harbour-lights'), autoplay: false);

    Future<void> shot(String name, String path, {Future<void> Function()? setup, int settleMs = 1400}) async {
      await setup?.call();
      await tester.pumpWidget(UncontrolledProviderScope(key: ValueKey('$name-$n'), container: c, child: InkwellApp(router: buildRouter(initial: path))));
      // Fixed pumps, not pumpAndSettle: the audio position stream never settles.
      for (var i = 0; i < 14; i++) {
        await tester.pump(Duration(milliseconds: settleMs ~/ 14));
      }
      n++;
      await binding.takeScreenshot('${n.toString().padLeft(2, '0')}-$name');
    }

    await shot('welcome', '/');
    await shot('sign-in', '/sign-in');
    await shot('today', '/today');
    await shot('daily-article', '/article/why-we-still-write-letters');
    await shot('library', '/library');
    await shot('book-detail', '/book/salt-road');
    await shot('epub-reader', '/read/salt-road', settleMs: 2000);
    await shot('reader-settings', '/read/salt-road?sheet=settings', settleMs: 2000);
    await shot('contents-bookmarks', '/read/salt-road/contents');
    await shot('audiobook-player', '/player');
    await shot('chapters-sleep', '/player?sheet=chapters', setup: () async => c.read(audioProvider.notifier).setSleep(SleepTimer.endOfChapter));
    await shot('search', '/search');
    await shot('reference-entry', '/reference/victorian-gold-rush');
    await shot('favourites', '/favourites');
    await shot('premium', '/premium');
    await shot('profile', '/profile');
    await shot('downloads', '/downloads');
    await shot('today-empty', '/today', setup: () async => c.read(sessionProvider.notifier).createAccount());
    await shot('library-empty', '/library');
  });
}
