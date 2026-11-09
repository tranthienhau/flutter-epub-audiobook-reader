# Regenerating screenshots and demo

1. Boot a simulator: `xcrun simctl boot "iPhone 17 Pro" && open -a Simulator`
2. `flutter pub get`
3. Optional, rebuild demo content (EPUBs + narration, macOS only): `python3 tool/build_content.py`
4. Screenshots (writes `screenshots/NN-name.png`):
   ```sh
   flutter drive --driver test_driver/integration_test.dart \
     --target integration_test/screenshot_test.dart -d "iPhone 17 Pro"
   ```
5. Demo walkthrough. iOS: `xcrun simctl io booted recordVideo --codec h264 demo.mp4` while running the command below, then Ctrl-C. Android: `adb shell screenrecord --time-limit 40 --size 540x1200 /sdcard/ademo.mp4` once the test starts, then `adb pull`.
   ```sh
   flutter drive --driver test_driver/integration_test.dart \
     --target integration_test/demo_test.dart -d <device>
   ```
6. GIF: ffmpeg palette pass, 12 fps, 300 px wide.

How it works: `screenshot_test.dart` keeps one `ProviderContainer` (signed-in reader, audiobook loaded but paused) and pumps the app once per screen with a router that starts at that route. Sheets open from a `?sheet=` query parameter. It uses fixed `pump(Duration)` calls instead of `pumpAndSettle` because the audio position stream never settles. The last two shots switch the session to a new free account to show the first-run empty states. Fonts are bundled, so no network is needed.
