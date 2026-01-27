/// LiftIQ - String Extensions
///
/// Utility extensions on String for common text transformations.
library;

/// Extension methods on String for text formatting.
extension StringExtensions on String {
  /// Converts the first character of each word to uppercase.
  ///
  /// Example: "quads" -> "Quads", "lower back" -> "Lower Back"
  ///
  /// Uses simple word splitting on spaces and capitalizes each word.
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  /// Capitalizes only the first character of the string.
  ///
  /// Example: "quads" -> "Quads", "lower back" -> "Lower back"
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
