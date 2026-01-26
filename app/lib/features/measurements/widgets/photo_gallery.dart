/// LiftIQ - Photo Gallery Widget
///
/// Displays progress photos in a grid layout.
/// Supports filtering by photo type and date comparison.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/body_measurement.dart';

/// Gallery view for progress photos.
class PhotoGallery extends StatefulWidget {
  /// Creates a photo gallery.
  const PhotoGallery({
    super.key,
    required this.photos,
  });

  /// Photos to display.
  final List<ProgressPhoto> photos;

  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  PhotoType? _selectedFilter;

  List<ProgressPhoto> get _filteredPhotos {
    if (_selectedFilter == null) return widget.photos;
    return widget.photos.where((p) => p.photoType == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _selectedFilter == null,
                onSelected: (_) => setState(() => _selectedFilter = null),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Front'),
                selected: _selectedFilter == PhotoType.front,
                onSelected: (_) => setState(() => _selectedFilter = PhotoType.front),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Side'),
                selected: _selectedFilter == PhotoType.sideLeft ||
                    _selectedFilter == PhotoType.sideRight,
                onSelected: (_) => setState(() => _selectedFilter = PhotoType.sideLeft),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Back'),
                selected: _selectedFilter == PhotoType.back,
                onSelected: (_) => setState(() => _selectedFilter = PhotoType.back),
              ),
            ],
          ),
        ),

        // Photo grid
        Expanded(
          child: _filteredPhotos.isEmpty
              ? Center(
                  child: Text(
                    'No photos match the filter',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _filteredPhotos.length,
                  itemBuilder: (context, index) {
                    final photo = _filteredPhotos[index];
                    return _PhotoCard(
                      photo: photo,
                      onTap: () => _showPhotoViewer(context, photo),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showPhotoViewer(BuildContext context, ProgressPhoto photo) {
    showDialog<void>(
      context: context,
      builder: (context) => _PhotoViewerDialog(
        photo: photo,
        allPhotos: _filteredPhotos,
      ),
    );
  }
}

/// Card displaying a single photo.
class _PhotoCard extends StatelessWidget {
  const _PhotoCard({
    required this.photo,
    required this.onTap,
  });

  final ProgressPhoto photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Photo placeholder (would use cached network image in production)
            Expanded(
              child: Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getIconForType(photo.photoType),
                        size: 48,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getTypeLabel(photo.photoType),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Info bar
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getIconForType(photo.photoType),
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getTypeLabel(photo.photoType),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat.yMMMd().format(photo.takenAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(PhotoType type) {
    switch (type) {
      case PhotoType.front:
        return Icons.person;
      case PhotoType.sideLeft:
        return Icons.arrow_back;
      case PhotoType.sideRight:
        return Icons.arrow_forward;
      case PhotoType.back:
        return Icons.person_outline;
    }
  }

  String _getTypeLabel(PhotoType type) {
    switch (type) {
      case PhotoType.front:
        return 'Front';
      case PhotoType.sideLeft:
        return 'Left Side';
      case PhotoType.sideRight:
        return 'Right Side';
      case PhotoType.back:
        return 'Back';
    }
  }
}

/// Full-screen photo viewer dialog.
class _PhotoViewerDialog extends StatefulWidget {
  const _PhotoViewerDialog({
    required this.photo,
    required this.allPhotos,
  });

  final ProgressPhoto photo;
  final List<ProgressPhoto> allPhotos;

  @override
  State<_PhotoViewerDialog> createState() => _PhotoViewerDialogState();
}

class _PhotoViewerDialogState extends State<_PhotoViewerDialog> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.allPhotos.indexOf(widget.photo);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photo = widget.allPhotos[_currentIndex];

    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(
            DateFormat.yMMMd().format(photo.takenAt),
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Photo viewer
            PageView.builder(
              controller: _pageController,
              itemCount: widget.allPhotos.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                final p = widget.allPhotos[index];
                return Center(
                  child: Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            size: 100,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Photo: ${_getTypeLabel(p.photoType)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat.yMMMd().format(p.takenAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Page indicators
            if (widget.allPhotos.length > 1)
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.allPhotos.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentIndex
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(PhotoType type) {
    switch (type) {
      case PhotoType.front:
        return 'Front';
      case PhotoType.sideLeft:
        return 'Left Side';
      case PhotoType.sideRight:
        return 'Right Side';
      case PhotoType.back:
        return 'Back';
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pop();
      // TODO: Call delete API
    }
  }
}
