import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../data/models.dart';
import 'providers.dart';

enum SleepTimer { off, m15, m30, m45, endOfChapter }

class NowPlaying {
  const NowPlaying({
    this.title,
    this.chapter,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.playing = false,
    this.speed = 1.0,
    this.sleep = SleepTimer.off,
    this.essayId,
  });

  final Book? title;
  final Chapter? chapter;
  final Duration position, duration;
  final bool playing;
  final double speed;
  final SleepTimer sleep;
  final String? essayId;

  bool get loaded => title != null || essayId != null;
  double get fraction => duration.inMilliseconds == 0 ? 0 : (position.inMilliseconds / duration.inMilliseconds).clamp(0, 1);

  NowPlaying copyWith({
    Book? title,
    Chapter? chapter,
    Duration? position,
    Duration? duration,
    bool? playing,
    double? speed,
    SleepTimer? sleep,
    String? essayId,
  }) => NowPlaying(
    title: title ?? this.title,
    chapter: chapter ?? this.chapter,
    position: position ?? this.position,
    duration: duration ?? this.duration,
    playing: playing ?? this.playing,
    speed: speed ?? this.speed,
    sleep: sleep ?? this.sleep,
    essayId: essayId ?? this.essayId,
  );
}

/// Streams audiobook chapters through just_audio. just_audio_background adds the
/// lock screen / Control Center / notification controls, interruption handling
/// (calls, unplugged headphones) and keeps playback alive in the background.
class AudioController extends Notifier<NowPlaying> {
  AudioPlayer? _player;
  final _subs = <StreamSubscription>[];
  Timer? _sleepTimer;

  AudioPlayer get _p => _player ??= _create();

  AudioPlayer _create() {
    final p = AudioPlayer();
    _subs
      ..add(p.positionStream.listen((d) => state = state.copyWith(position: d)))
      ..add(p.durationStream.listen((d) => state = state.copyWith(duration: d ?? Duration.zero)))
      ..add(p.playingStream.listen((v) => state = state.copyWith(playing: v)))
      ..add(
        p.processingStateStream.listen((s) {
          if (s == ProcessingState.completed && state.sleep == SleepTimer.endOfChapter) {
            p.pause();
            state = state.copyWith(sleep: SleepTimer.off);
          }
        }),
      );
    return p;
  }

  @override
  NowPlaying build() {
    ref.onDispose(() {
      for (final s in _subs) {
        s.cancel();
      }
      _sleepTimer?.cancel();
      _player?.dispose();
    });
    return const NowPlaying();
  }

  /// Opens a chapter. In production the source is a signed, expiring HLS / MP3
  /// URL from the CDN; the POC streams the bundled sample through the same API.
  Future<void> open(Book t, {int? chapterIndex, Duration start = const Duration(seconds: 18), bool autoplay = true}) async {
    final idx = chapterIndex ?? ref.read(progressProvider)[t.id]?.chapter ?? 0;
    final ch = t.chapters.isEmpty ? null : t.chapters[idx.clamp(0, t.chapters.length - 1)];
    state = state.copyWith(title: t, chapter: ch);
    await _p.setAudioSource(
      AudioSource.asset(
        'assets/audio/${t.audio ?? 'harbour-lights-ch12.m4a'}',
        tag: MediaItem(
          id: '${t.id}-${ch?.n ?? 0}',
          title: ch == null ? t.title : 'Ch ${ch.n} · ${ch.title}',
          album: t.title,
          artist: '${t.author} · read by ${t.narrator ?? ''}',
          artUri: Uri.parse('asset:///${t.coverAsset}'),
        ),
      ),
      initialPosition: start,
    );
    await _p.setSpeed(state.speed);
    if (autoplay) unawaited(_p.play());
  }

  Future<void> openEssay(DailyPiece d) async {
    state = NowPlaying(essayId: d.id, speed: state.speed);
    await _p.setAudioSource(
      AudioSource.asset(
        'assets/audio/${d.audio}',
        tag: MediaItem(id: d.id, title: d.title, artist: d.author, album: 'Inkwell Daily'),
      ),
    );
    unawaited(_p.play());
  }

  void toggle() => state.playing ? _p.pause() : _p.play();
  void seekRelative(int seconds) {
    final target = state.position + Duration(seconds: seconds);
    _p.seek(target < Duration.zero ? Duration.zero : (target > state.duration ? state.duration : target));
  }

  void seekFraction(double f) => _p.seek(state.duration * f);

  void cycleSpeed() {
    const speeds = [1.0, 1.25, 1.5, 1.75, 2.0, 0.8];
    final next = speeds[(speeds.indexOf(state.speed) + 1) % speeds.length];
    _p.setSpeed(next);
    state = state.copyWith(speed: next);
  }

  void selectChapter(int index) {
    final t = state.title;
    if (t != null && index >= 0 && index < t.chapters.length) open(t, chapterIndex: index, start: Duration.zero);
  }

  void setSleep(SleepTimer s) {
    _sleepTimer?.cancel();
    state = state.copyWith(sleep: s);
    final minutes = switch (s) {
      SleepTimer.m15 => 15,
      SleepTimer.m30 => 30,
      SleepTimer.m45 => 45,
      _ => 0,
    };
    if (minutes > 0) {
      _sleepTimer = Timer(Duration(minutes: minutes), () {
        _p.pause();
        state = state.copyWith(sleep: SleepTimer.off);
      });
    }
  }
}

final audioProvider = NotifierProvider<AudioController, NowPlaying>(AudioController.new);

String fmt(Duration d) {
  final m = d.inMinutes, s = d.inSeconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}
