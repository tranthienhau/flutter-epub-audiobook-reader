# Inkwell - Source Brief

## Title
Inkwell - Read it. Hear it. Every day.

## Description
Inkwell is a reading and listening app for an Australian publisher. Readers open EPUB ebooks in a paginated reader with themes, fonts, bookmarks and highlights, stream audiobooks with lock-screen controls, a sleep timer and speed control, and can switch from the page to the narration at the same chapter. Each morning a new editorial piece appears on the Today tab, and a reference library sits alongside the catalogue in one search. Accounts sync bookmarks and favourites, and a premium membership unlocks the full catalogue and offline downloads.

## Store links
Not yet published (proof of concept).

## Platform
Both (iOS and Android, one Flutter codebase).

## Category
Books and reference; audiobooks; digital publishing.

## Features
- EPUB ebook reader: on-device EPUB parsing, measured pagination, table of contents, page scrubber
- Reading themes (White, Paper, Sepia, Night), font size, four font choices, line spacing, margins, scroll mode
- Bookmarks with swipe-to-delete and highlights
- Audiobook streaming with background playback, lock screen and notification controls
- Skip 15 s back / 30 s forward, playback speed, chapter list, sleep timer (15 / 30 / 45 min, end of chapter)
- Mini player above the tab bar
- "Switch to audio at this spot" from the reader
- Today feed with a daily essay, essay narration and a link to the author's book
- Ranked search across ebooks, audiobooks, daily essays and reference entries, with filters
- Reference entries with quick facts, related titles and see-also links
- Sign in, create a free account, first-run empty states
- Favourites across books, essays and reference
- Free and premium membership: premium badges, paywall with annual and monthly plans, trial, restore
- Offline downloads with storage summary, pause / resume and Wi-Fi only

## Tech stack
- Flutter 3 / Dart 3
- State: Riverpod 3 (Notifier, FutureProvider)
- Navigation: go_router with StatefulShellRoute tabs
- EPUB: archive + xml packages, custom TextPainter paginator
- Audio: just_audio + just_audio_background
- Content: JSON payload shaped like a headless CMS response
- Testing: flutter_test unit tests, integration_test screenshot and demo drivers

## Industry
Publishing, digital books and audiobooks.

## Metrics
Unpublished POC, no store metrics. Scope: 17 screens plus 2 first-run states, 6 bundled EPUBs, 3 narration samples, unit tests for EPUB parsing and pagination.

## Research notes
- Verified: EPUB parsing and pagination run on device against real EPUB 3 packages; audio playback, speed, seek and sleep timer run through just_audio on iOS Simulator and Android Emulator.
- Mocked: catalogue, daily pieces and reference entries come from a bundled JSON file; sign-in, membership purchase and downloads are local simulations; one chapter per audiobook is narrated.
- All book text, essays and narration are original demo content.
- Future expansion: headless CMS with editorial workflow, Supabase or Firebase account sync, RevenueCat subscriptions, signed CDN audio with HLS, resumable downloads, Readium-based EPUB rendering for complex layouts and fixed-layout books, CarPlay and Android Auto.
