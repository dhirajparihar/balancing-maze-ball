/// Audio manager — centralized sound effects and music control.
/// Uses audioplayers package. Provides placeholder integration points
/// for all game sounds.
library;

import 'package:audioplayers/audioplayers.dart';
import '../../models/maze_theme_config.dart';
import '../../models/player_data.dart';

enum SoundEffect {
  buttonTap,
  marbleRoll,
  marbleCollision,
  coinCollect,
  starCollect,
  powerUpActivate,
  checkpoint,
  timerWarning,
  victory,
  failure,
  revive,
  purchase,
  themeUnlock,
  achievementUnlock,
  countdown,
  fallOut,
  menuTransition,
  ratchet,
  clankBrass,
  clankTimber,
  clankCeramic,
  tapeCrack,
}

enum MusicTrack {
  homeMenu,
  gameplay,
  victory,
  failure,
  shop,
}

class AudioManager {
  final bool isEnabled;
  AudioPlayer? _musicPlayer;
  final Map<SoundEffect, AudioPlayer> _sfxPlayers = {};
  DateTime _lastRatchetTime = DateTime.fromMillisecondsSinceEpoch(0);
  
  double _musicVolume = 0.7;
  double _sfxVolume = 1.0;
  bool _isMuted = false;
  MusicTrack? _currentTrack;

  AudioManager({this.isEnabled = true}) {
    if (isEnabled) {
      try {
        _musicPlayer = AudioPlayer();
      } catch (_) {
        _musicPlayer = null;
      }
    }
  }

  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  Future<void> initialize(PlayerData playerData) async {
    _musicVolume = playerData.musicVolume;
    _sfxVolume = playerData.sfxVolume;
    if (!isEnabled || _musicPlayer == null) return;
    try {
      await _musicPlayer?.setReleaseMode(ReleaseMode.loop);
    } catch (_) {}
  }

  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    if (!isEnabled || _musicPlayer == null) return;
    try {
      _musicPlayer?.setVolume(_musicVolume);
    } catch (_) {}
  }

  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
  }

  void setMuted(bool muted) {
    _isMuted = muted;
    if (!isEnabled || _musicPlayer == null) return;
    try {
      if (muted) {
        _musicPlayer?.setVolume(0);
      } else {
        _musicPlayer?.setVolume(_musicVolume);
      }
    } catch (_) {}
  }

  /// Play a sound effect (.wav with fallback to .mp3)
  Future<void> playSfx(SoundEffect effect) async {
    if (!isEnabled || _isMuted || _sfxVolume <= 0) return;
    try {
      final player = _sfxPlayers[effect] ?? AudioPlayer();
      _sfxPlayers[effect] = player;
      await player.setVolume(_sfxVolume);

      // Determine asset filename
      String fileName;
      switch (effect) {
        case SoundEffect.ratchet:
          fileName = 'sfx_ratchet.wav';
          break;
        case SoundEffect.clankBrass:
          fileName = 'sfx_clank_brass.wav';
          break;
        case SoundEffect.clankTimber:
          fileName = 'sfx_clank_timber.wav';
          break;
        case SoundEffect.clankCeramic:
          fileName = 'sfx_clank_ceramic.wav';
          break;
        case SoundEffect.tapeCrack:
          fileName = 'sfx_tape_crack.wav';
          break;
        default:
          fileName = 'sfx_${effect.name}.wav';
      }

      await player.setSource(AssetSource('audio/$fileName'));
      await player.resume();
    } catch (_) {
      // Asset not available — silent placeholder
    }
  }

  /// Play physical thumb ratchet micro-click (debounced at 35ms)
  void playRatchetClick() {
    if (!isEnabled) return;
    final now = DateTime.now();
    if (now.difference(_lastRatchetTime).inMilliseconds >= 35) {
      _lastRatchetTime = now;
      playSfx(SoundEffect.ratchet);
    }
  }

  /// Play theme-specific marble impact clank
  void playThemeClank(ThemeType theme) {
    if (!isEnabled) return;
    switch (theme) {
      case ThemeType.steampunkBrass:
        playSfx(SoundEffect.clankBrass);
        break;
      case ThemeType.jungleBamboo:
        playSfx(SoundEffect.clankTimber);
        break;
      case ThemeType.classicCyan:
      default:
        playSfx(SoundEffect.clankCeramic);
        break;
    }
  }

  /// Play taped hole cover tearing / breaking
  void playTapeCrack() {
    if (!isEnabled) return;
    playSfx(SoundEffect.tapeCrack);
  }

  /// Play a music track with crossfade.
  Future<void> playMusic(MusicTrack track) async {
    if (!isEnabled || _musicPlayer == null || track == _currentTrack) return;
    _currentTrack = track;
    try {
      // Simple crossfade: stop current, start new
      await _musicPlayer?.stop();
      await _musicPlayer?.setVolume(_isMuted ? 0 : _musicVolume);
      await _musicPlayer?.setSource(AssetSource('audio/music_${track.name}.wav'));
      await _musicPlayer?.resume();
    } catch (_) {
      // Asset not available — silent placeholder
    }
  }

  Future<void> stopMusic() async {
    _currentTrack = null;
    if (!isEnabled || _musicPlayer == null) return;
    try {
      await _musicPlayer?.stop();
    } catch (_) {}
  }

  Future<void> pauseMusic() async {
    if (!isEnabled || _musicPlayer == null) return;
    try {
      await _musicPlayer?.pause();
    } catch (_) {}
  }

  Future<void> resumeMusic() async {
    if (!isEnabled || _musicPlayer == null) return;
    if (_currentTrack != null) {
      try {
        await _musicPlayer?.resume();
      } catch (_) {}
    }
  }

  void dispose() {
    try {
      _musicPlayer?.dispose();
    } catch (_) {}
    for (final player in _sfxPlayers.values) {
      try {
        player.dispose();
      } catch (_) {}
    }
    _sfxPlayers.clear();
  }
}
