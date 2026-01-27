/// LiftIQ - Music Service
///
/// Handles integration with music playback on the device.
/// Provides controls for play/pause, skip, and now playing information.
///
/// Note: This service interacts with the system's media controls.
/// On iOS, it uses MPNowPlayingInfoCenter.
/// On Android, it uses MediaSession API.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

/// State of currently playing music.
class MusicState {
  /// Whether music is currently playing.
  final bool isPlaying;

  /// Name of the current track.
  final String? trackName;

  /// Name of the artist.
  final String? artistName;

  /// Name of the album.
  final String? albumName;

  /// URL or path to album artwork (may be null).
  final String? albumArtUrl;

  /// Duration of the track in milliseconds.
  final int? durationMs;

  /// Current position in milliseconds.
  final int? positionMs;

  /// Name of the source app (Spotify, Apple Music, etc.)
  final String? sourceApp;

  const MusicState({
    this.isPlaying = false,
    this.trackName,
    this.artistName,
    this.albumName,
    this.albumArtUrl,
    this.durationMs,
    this.positionMs,
    this.sourceApp,
  });

  /// Empty state when no music is playing.
  static const MusicState empty = MusicState();

  /// Whether there is any track information available.
  bool get hasTrackInfo => trackName != null || artistName != null;

  /// Progress as a fraction (0.0 to 1.0).
  double get progress {
    if (durationMs == null || positionMs == null || durationMs == 0) {
      return 0.0;
    }
    return (positionMs! / durationMs!).clamp(0.0, 1.0);
  }

  /// Formatted duration string (e.g., "3:45").
  String get formattedDuration {
    if (durationMs == null) return '--:--';
    return _formatDuration(durationMs!);
  }

  /// Formatted position string (e.g., "1:23").
  String get formattedPosition {
    if (positionMs == null) return '--:--';
    return _formatDuration(positionMs!);
  }

  String _formatDuration(int ms) {
    final seconds = (ms / 1000).round();
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  MusicState copyWith({
    bool? isPlaying,
    String? trackName,
    String? artistName,
    String? albumName,
    String? albumArtUrl,
    int? durationMs,
    int? positionMs,
    String? sourceApp,
  }) {
    return MusicState(
      isPlaying: isPlaying ?? this.isPlaying,
      trackName: trackName ?? this.trackName,
      artistName: artistName ?? this.artistName,
      albumName: albumName ?? this.albumName,
      albumArtUrl: albumArtUrl ?? this.albumArtUrl,
      durationMs: durationMs ?? this.durationMs,
      positionMs: positionMs ?? this.positionMs,
      sourceApp: sourceApp ?? this.sourceApp,
    );
  }
}

/// Service for controlling music playback.
///
/// ## Usage
/// ```dart
/// final musicService = MusicService();
///
/// // Listen for state changes
/// musicService.stateStream.listen((state) {
///   if (state.isPlaying) {
///     print('Now playing: ${state.trackName}');
///   }
/// });
///
/// // Control playback
/// await musicService.togglePlayPause();
/// await musicService.skipNext();
/// ```
class MusicService {
  /// Singleton instance.
  static final MusicService _instance = MusicService._internal();

  factory MusicService() => _instance;

  MusicService._internal();

  /// Controller for music state stream.
  final _stateController = StreamController<MusicState>.broadcast();

  /// Current music state.
  MusicState _currentState = MusicState.empty;

  /// Whether the service is initialized.
  bool _isInitialized = false;

  /// Stream of music state updates.
  Stream<MusicState> get stateStream => _stateController.stream;

  /// Current music state.
  MusicState get currentState => _currentState;

  /// Whether music is currently playing.
  bool get isPlaying => _currentState.isPlaying;

  /// Whether there's any track info available.
  bool get hasTrackInfo => _currentState.hasTrackInfo;

  /// Initialize the music service.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // In a real implementation, this would:
    // 1. Set up platform channel listeners for media session updates
    // 2. Register as a media controller client
    // 3. Start listening for now-playing changes

    _isInitialized = true;
    debugPrint('MusicService initialized');

    // Simulate initial state check
    await _refreshState();
  }

  /// Dispose of the music service.
  void dispose() {
    _stateController.close();
    _isInitialized = false;
  }

  /// Toggle play/pause.
  Future<void> togglePlayPause() async {
    if (!_isInitialized) await initialize();

    try {
      // In a real implementation, this would use platform channels
      // to send a play/pause command to the system media controller.

      // Simulate the action
      _currentState = _currentState.copyWith(isPlaying: !_currentState.isPlaying);
      _stateController.add(_currentState);

      debugPrint('Music ${_currentState.isPlaying ? 'playing' : 'paused'}');
    } catch (e) {
      debugPrint('Error toggling play/pause: $e');
    }
  }

  /// Play the current track.
  Future<void> play() async {
    if (!_isInitialized) await initialize();

    try {
      _currentState = _currentState.copyWith(isPlaying: true);
      _stateController.add(_currentState);
      debugPrint('Music playing');
    } catch (e) {
      debugPrint('Error playing: $e');
    }
  }

  /// Pause the current track.
  Future<void> pause() async {
    if (!_isInitialized) await initialize();

    try {
      _currentState = _currentState.copyWith(isPlaying: false);
      _stateController.add(_currentState);
      debugPrint('Music paused');
    } catch (e) {
      debugPrint('Error pausing: $e');
    }
  }

  /// Skip to the next track.
  Future<void> skipNext() async {
    if (!_isInitialized) await initialize();

    try {
      // In a real implementation, this would send a skip command
      // to the system media controller.
      debugPrint('Skipping to next track');

      // Simulate state change
      await _refreshState();
    } catch (e) {
      debugPrint('Error skipping next: $e');
    }
  }

  /// Skip to the previous track.
  Future<void> skipPrevious() async {
    if (!_isInitialized) await initialize();

    try {
      debugPrint('Skipping to previous track');
      await _refreshState();
    } catch (e) {
      debugPrint('Error skipping previous: $e');
    }
  }

  /// Open the preferred music app.
  Future<void> openMusicApp(String appName) async {
    // In a real implementation, this would use url_launcher to
    // open the specified music app.

    final schemes = {
      'spotify': 'spotify://',
      'apple_music': 'music://',
      'youtube_music': 'https://music.youtube.com',
    };

    final scheme = schemes[appName.toLowerCase()];
    if (scheme != null) {
      debugPrint('Opening music app: $appName');
      // await launchUrl(Uri.parse(scheme));
    }
  }

  /// Refresh the current music state.
  Future<void> _refreshState() async {
    // In a real implementation, this would query the system's
    // current now-playing information.

    // For demo purposes, we'll simulate some state
    // In production, this would be replaced with actual platform calls
  }

  /// Update the state from platform events.
  void _handlePlatformUpdate(Map<String, dynamic> data) {
    _currentState = MusicState(
      isPlaying: data['isPlaying'] as bool? ?? false,
      trackName: data['trackName'] as String?,
      artistName: data['artistName'] as String?,
      albumName: data['albumName'] as String?,
      albumArtUrl: data['albumArtUrl'] as String?,
      durationMs: data['durationMs'] as int?,
      positionMs: data['positionMs'] as int?,
      sourceApp: data['sourceApp'] as String?,
    );
    _stateController.add(_currentState);
  }
}

/// List of supported music apps.
enum MusicApp {
  /// Spotify
  spotify,

  /// Apple Music
  appleMusic,

  /// YouTube Music
  youtubeMusic,

  /// System music player
  system,
}

/// Extension for MusicApp display properties.
extension MusicAppExtension on MusicApp {
  /// Display name of the app.
  String get displayName {
    switch (this) {
      case MusicApp.spotify:
        return 'Spotify';
      case MusicApp.appleMusic:
        return 'Apple Music';
      case MusicApp.youtubeMusic:
        return 'YouTube Music';
      case MusicApp.system:
        return 'System Player';
    }
  }

  /// URL scheme to open the app.
  String get urlScheme {
    switch (this) {
      case MusicApp.spotify:
        return 'spotify://';
      case MusicApp.appleMusic:
        return 'music://';
      case MusicApp.youtubeMusic:
        return 'https://music.youtube.com';
      case MusicApp.system:
        return '';
    }
  }
}
