/// LiftIQ - Music Mini Player Widget
///
/// Compact music control bar for the active workout screen.
/// Shows current track info and play/pause/skip controls.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/music_service.dart';
import '../../settings/providers/settings_provider.dart';

/// Provider for the music service.
final musicServiceProvider = Provider<MusicService>((ref) {
  return MusicService();
});

/// Provider for music state stream.
final musicStateProvider = StreamProvider<MusicState>((ref) {
  final service = ref.watch(musicServiceProvider);
  service.initialize();
  return service.stateStream;
});

/// Compact music player bar for the workout screen.
///
/// ## Usage
/// ```dart
/// MusicMiniPlayer(
///   onTap: () => showMusicDetails(),
/// )
/// ```
class MusicMiniPlayer extends ConsumerWidget {
  /// Called when the player bar is tapped.
  final VoidCallback? onTap;

  const MusicMiniPlayer({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showControls = ref.watch(showMusicControlsProvider);
    final musicStateAsync = ref.watch(musicStateProvider);

    // Don't show if disabled in settings
    if (!showControls) return const SizedBox.shrink();

    return musicStateAsync.when(
      data: (state) {
        // Only show if there's track info
        if (!state.hasTrackInfo) return const SizedBox.shrink();
        return _MusicMiniPlayerContent(
          state: state,
          onTap: onTap,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _MusicMiniPlayerContent extends ConsumerStatefulWidget {
  final MusicState state;
  final VoidCallback? onTap;

  const _MusicMiniPlayerContent({
    required this.state,
    this.onTap,
  });

  @override
  ConsumerState<_MusicMiniPlayerContent> createState() =>
      _MusicMiniPlayerContentState();
}

class _MusicMiniPlayerContentState
    extends ConsumerState<_MusicMiniPlayerContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Album art placeholder
                  _buildAlbumArt(colors),
                  const SizedBox(width: 12),

                  // Track info
                  Expanded(
                    child: _buildTrackInfo(theme, colors),
                  ),

                  // Controls
                  _buildControls(colors),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumArt(ColorScheme colors) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: widget.state.albumArtUrl != null
          ? Image.network(
              widget.state.albumArtUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildMusicIcon(colors),
            )
          : _buildMusicIcon(colors),
    );
  }

  Widget _buildMusicIcon(ColorScheme colors) {
    return Container(
      color: colors.primaryContainer,
      child: Icon(
        Icons.music_note,
        color: colors.onPrimaryContainer,
        size: 24,
      ),
    );
  }

  Widget _buildTrackInfo(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Track name with marquee effect for long names
        Text(
          widget.state.trackName ?? 'Unknown Track',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        // Artist name
        Text(
          widget.state.artistName ?? 'Unknown Artist',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildControls(ColorScheme colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Previous button
        IconButton(
          icon: const Icon(Icons.skip_previous_rounded),
          iconSize: 24,
          color: colors.onSurface,
          onPressed: _skipPrevious,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),

        // Play/Pause button
        IconButton(
          icon: Icon(
            widget.state.isPlaying
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
          ),
          iconSize: 32,
          color: colors.onSurface,
          onPressed: _togglePlayPause,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        ),

        // Next button
        IconButton(
          icon: const Icon(Icons.skip_next_rounded),
          iconSize: 24,
          color: colors.onSurface,
          onPressed: _skipNext,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      ],
    );
  }

  void _togglePlayPause() {
    HapticFeedback.lightImpact();
    ref.read(musicServiceProvider).togglePlayPause();
  }

  void _skipNext() {
    HapticFeedback.lightImpact();
    ref.read(musicServiceProvider).skipNext();
  }

  void _skipPrevious() {
    HapticFeedback.lightImpact();
    ref.read(musicServiceProvider).skipPrevious();
  }
}

/// Expanded music player sheet for more controls.
class MusicPlayerSheet extends ConsumerWidget {
  const MusicPlayerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final musicStateAsync = ref.watch(musicStateProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      child: musicStateAsync.when(
        data: (state) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Album art
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: state.albumArtUrl != null
                  ? Image.network(
                      state.albumArtUrl!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: colors.primaryContainer,
                      child: Icon(
                        Icons.music_note,
                        size: 80,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
            ),
            const SizedBox(height: 24),

            // Track info
            Text(
              state.trackName ?? 'Not Playing',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              state.artistName ?? '',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Progress bar
            LinearProgressIndicator(
              value: state.progress,
              backgroundColor: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(2),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  state.formattedPosition,
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  state.formattedDuration,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Large controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded),
                  iconSize: 48,
                  onPressed: () => ref.read(musicServiceProvider).skipPrevious(),
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      state.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    iconSize: 56,
                    color: colors.onPrimary,
                    onPressed: () =>
                        ref.read(musicServiceProvider).togglePlayPause(),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded),
                  iconSize: 48,
                  onPressed: () => ref.read(musicServiceProvider).skipNext(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // App links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _AppButton(
                  label: 'Spotify',
                  icon: Icons.audiotrack,
                  onTap: () =>
                      ref.read(musicServiceProvider).openMusicApp('spotify'),
                ),
                const SizedBox(width: 16),
                _AppButton(
                  label: 'Apple Music',
                  icon: Icons.apple,
                  onTap: () =>
                      ref.read(musicServiceProvider).openMusicApp('apple_music'),
                ),
                const SizedBox(width: 16),
                _AppButton(
                  label: 'YouTube',
                  icon: Icons.play_circle_outline,
                  onTap: () => ref
                      .read(musicServiceProvider)
                      .openMusicApp('youtube_music'),
                ),
              ],
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _AppButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _AppButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows the music player sheet.
void showMusicPlayerSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => const MusicPlayerSheet(),
    isScrollControlled: true,
  );
}
