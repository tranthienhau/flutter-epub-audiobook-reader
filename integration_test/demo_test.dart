import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:inkwell/app.dart';

/// Scripted ~25 s walkthrough used to record the README demo GIFs.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('demo walkthrough', (tester) async {
    await bootstrap();
    await tester.pumpWidget(ProviderScope(child: InkwellApp()));
    Future<void> wait(int ms) async {
      for (var i = 0; i < ms ~/ 100; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> tap(String key, {int after = 1300}) async {
      await tester.tap(find.byKey(ValueKey(key)).first);
      await wait(after);
    }

    await wait(1800); // welcome
    await tap('have-account');
    await tap('sign-in', after: 2000); // Today
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -300));
    await wait(1200);
    await tap('new-salt-road'); // book detail
    await tap('read', after: 2200); // EPUB reader
    await tester.fling(find.byType(PageView), const Offset(-300, 0), 1200);
    await wait(1200);
    await tap('aa', after: 1200); // display sheet
    await tap('theme-sepia', after: 900);
    await tap('font-Serif', after: 1200);
    await tester.tapAt(const Offset(200, 120)); // dismiss sheet
    await wait(1200);
    await tap('switch-audio', after: 2600); // player, audio streaming
    await tap('speed', after: 900);
    await tap('chapters', after: 1800);
    await tester.tapAt(const Offset(200, 120));
    await wait(800);
    await tap('collapse', after: 800);
    await tap('back', after: 900);
    await tap('back', after: 900);
    await tap('tab-search', after: 1800);
    await tap('tab-profile', after: 1200);
    await tap('upgrade', after: 1800); // paywall
    await tap('start-trial', after: 1500);
  });
}
