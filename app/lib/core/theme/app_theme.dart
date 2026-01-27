/// LiftIQ App Theme Configuration
///
/// Defines 5 unique visual themes for the app:
/// 1. Midnight Surge - Dark, minimal, electric cyan
/// 2. Warm Lift - Light, friendly, coral orange
/// 3. Iron Brutalist - High contrast, bold red, sharp edges
/// 4. Neon Gym - Dark, retro-futuristic, neon glow
/// 5. Clean Slate - Light, minimal, subtle slate
///
/// Each theme includes:
/// - Custom color scheme
/// - Typography configuration
/// - Border radius preferences
/// - Shadow/elevation styles
/// - Component-specific overrides
library;

import 'package:flutter/material.dart';

import '../../features/settings/models/user_settings.dart';

// ============================================================================
// THEME COLORS
// ============================================================================

/// Color definitions for Midnight Surge theme.
///
/// Dark theme with electric cyan and purple accents.
/// Minimalist, data-forward, subtle borders.
abstract final class MidnightSurgeColors {
  static const background = Color(0xFF0A0A0F);
  static const surface = Color(0xFF141420);
  static const surfaceContainer = Color(0xFF1A1A2A);
  static const primary = Color(0xFF00D4FF); // Electric cyan
  static const secondary = Color(0xFF7C3AED); // Purple
  static const onPrimary = Color(0xFF000000);
  static const onSecondary = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA0A0B0);
  static const outline = Color(0xFF2A2A3A);
  static const error = Color(0xFFFF6B6B);
  static const success = Color(0xFF4ADE80);
}

/// Color definitions for Warm Lift theme.
///
/// Light theme with coral orange and peach accents.
/// Rounded, friendly design with soft shadows.
abstract final class WarmLiftColors {
  static const background = Color(0xFFFAF7F4);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceContainer = Color(0xFFF5F0EB);
  static const primary = Color(0xFFF97316); // Coral orange
  static const secondary = Color(0xFFFB923C); // Peach
  static const onPrimary = Color(0xFFFFFFFF);
  static const onSecondary = Color(0xFF1C1917);
  static const textPrimary = Color(0xFF1C1917);
  static const textSecondary = Color(0xFF78716C);
  static const outline = Color(0xFFE7E5E4);
  static const error = Color(0xFFDC2626);
  static const success = Color(0xFF16A34A);
}

/// Color definitions for Iron Brutalist theme.
///
/// High contrast with bold red and black accents.
/// Sharp corners, thick borders, no shadows.
abstract final class IronBrutalistColors {
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF5F5F5);
  static const surfaceContainer = Color(0xFFEEEEEE);
  static const primary = Color(0xFFDC2626); // Bold red
  static const secondary = Color(0xFF000000); // Black
  static const onPrimary = Color(0xFFFFFFFF);
  static const onSecondary = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0xFF525252);
  static const outline = Color(0xFF000000);
  static const error = Color(0xFFB91C1C);
  static const success = Color(0xFF166534);
}

/// Color definitions for Neon Gym theme.
///
/// Dark retro-futuristic with hot pink and cyan.
/// Subtle glows, rounded corners, neon aesthetic.
abstract final class NeonGymColors {
  static const background = Color(0xFF0F0F1A);
  static const surface = Color(0xFF1A1A2E);
  static const surfaceContainer = Color(0xFF252542);
  static const primary = Color(0xFFFF2D95); // Hot pink
  static const secondary = Color(0xFF00FFF0); // Cyan
  static const onPrimary = Color(0xFFFFFFFF);
  static const onSecondary = Color(0xFF000000);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF8888AA);
  static const outline = Color(0xFF3A3A5A);
  static const error = Color(0xFFFF4444);
  static const success = Color(0xFF00FF88);
}

/// Color definitions for Clean Slate theme.
///
/// Minimal light theme with slate and subtle lime.
/// Lots of whitespace, very subtle shadows.
abstract final class CleanSlateColors {
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceContainer = Color(0xFFF1F5F9);
  static const primary = Color(0xFF64748B); // Slate
  static const secondary = Color(0xFF84CC16); // Subtle lime for success
  static const onPrimary = Color(0xFFFFFFFF);
  static const onSecondary = Color(0xFF1E293B);
  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF94A3B8);
  static const outline = Color(0xFFE2E8F0);
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF22C55E);
}

/// Color definitions for Shadcn Dark theme.
///
/// Minimalist dark theme inspired by shadcn/ui.
/// Uses zinc color palette with subtle borders and clean aesthetic.
abstract final class ShadcnDarkColors {
  static const background = Color(0xFF09090B); // zinc-950
  static const surface = Color(0xFF18181B); // zinc-900
  static const surfaceContainer = Color(0xFF27272A); // zinc-800
  static const primary = Color(0xFFFAFAFA); // zinc-50 (white primary)
  static const secondary = Color(0xFF71717A); // zinc-500
  static const onPrimary = Color(0xFF18181B); // zinc-900
  static const onSecondary = Color(0xFFFAFAFA); // zinc-50
  static const textPrimary = Color(0xFFFAFAFA); // zinc-50
  static const textSecondary = Color(0xFFA1A1AA); // zinc-400
  static const outline = Color(0xFF27272A); // zinc-800
  static const error = Color(0xFFEF4444); // red-500
  static const success = Color(0xFF22C55E); // green-500
}

// ============================================================================
// THEME CONFIGURATION
// ============================================================================

/// Configuration for each theme's style properties.
class ThemeConfig {
  final double borderRadius;
  final double cardBorderRadius;
  final double buttonBorderRadius;
  final double borderWidth;
  final double cardElevation;
  final double buttonElevation;
  final FontWeight headingWeight;
  final FontWeight bodyWeight;
  final FontWeight numberWeight;
  final bool uppercaseHeadings;
  final List<BoxShadow>? accentGlow;

  const ThemeConfig({
    this.borderRadius = 12.0,
    this.cardBorderRadius = 16.0,
    this.buttonBorderRadius = 12.0,
    this.borderWidth = 1.0,
    this.cardElevation = 0.0,
    this.buttonElevation = 0.0,
    this.headingWeight = FontWeight.w600,
    this.bodyWeight = FontWeight.w400,
    this.numberWeight = FontWeight.w700,
    this.uppercaseHeadings = false,
    this.accentGlow,
  });
}

/// Theme configurations for each preset.
abstract final class ThemeConfigs {
  /// Midnight Surge: Minimalist, subtle borders, no heavy shadows
  static const midnightSurge = ThemeConfig(
    borderRadius: 12.0,
    cardBorderRadius: 16.0,
    buttonBorderRadius: 10.0,
    borderWidth: 1.0,
    cardElevation: 0.0,
    buttonElevation: 0.0,
    headingWeight: FontWeight.w600,
    bodyWeight: FontWeight.w400,
    numberWeight: FontWeight.w700,
    uppercaseHeadings: false,
  );

  /// Warm Lift: Rounded corners, soft shadows
  static const warmLift = ThemeConfig(
    borderRadius: 14.0,
    cardBorderRadius: 16.0,
    buttonBorderRadius: 14.0,
    borderWidth: 0.0,
    cardElevation: 2.0,
    buttonElevation: 1.0,
    headingWeight: FontWeight.w600,
    bodyWeight: FontWeight.w500,
    numberWeight: FontWeight.w600,
    uppercaseHeadings: false,
  );

  /// Iron Brutalist: Sharp corners, thick borders, no shadows
  static const ironBrutalist = ThemeConfig(
    borderRadius: 0.0,
    cardBorderRadius: 0.0,
    buttonBorderRadius: 0.0,
    borderWidth: 3.0,
    cardElevation: 0.0,
    buttonElevation: 0.0,
    headingWeight: FontWeight.w800,
    bodyWeight: FontWeight.w400,
    numberWeight: FontWeight.w900,
    uppercaseHeadings: true,
  );

  /// Neon Gym: Rounded corners, subtle glow effects
  static const neonGym = ThemeConfig(
    borderRadius: 12.0,
    cardBorderRadius: 16.0,
    buttonBorderRadius: 12.0,
    borderWidth: 1.0,
    cardElevation: 0.0,
    buttonElevation: 0.0,
    headingWeight: FontWeight.w600,
    bodyWeight: FontWeight.w400,
    numberWeight: FontWeight.w700,
    uppercaseHeadings: false,
    accentGlow: [
      BoxShadow(
        color: Color(0x40FF2D95),
        blurRadius: 20,
        spreadRadius: 0,
      ),
    ],
  );

  /// Clean Slate: Rounded corners, very subtle shadows
  static const cleanSlate = ThemeConfig(
    borderRadius: 8.0,
    cardBorderRadius: 12.0,
    buttonBorderRadius: 8.0,
    borderWidth: 1.0,
    cardElevation: 1.0,
    buttonElevation: 0.0,
    headingWeight: FontWeight.w500,
    bodyWeight: FontWeight.w400,
    numberWeight: FontWeight.w600,
    uppercaseHeadings: false,
  );

  /// Shadcn Dark: Clean minimalist dark with subtle borders
  static const shadcnDark = ThemeConfig(
    borderRadius: 8.0,
    cardBorderRadius: 8.0,
    buttonBorderRadius: 6.0,
    borderWidth: 1.0,
    cardElevation: 0.0,
    buttonElevation: 0.0,
    headingWeight: FontWeight.w600,
    bodyWeight: FontWeight.w400,
    numberWeight: FontWeight.w500,
    uppercaseHeadings: false,
  );

  /// Gets the config for a given theme.
  static ThemeConfig forTheme(LiftIQTheme theme) => switch (theme) {
    LiftIQTheme.midnightSurge => midnightSurge,
    LiftIQTheme.warmLift => warmLift,
    LiftIQTheme.ironBrutalist => ironBrutalist,
    LiftIQTheme.neonGym => neonGym,
    LiftIQTheme.cleanSlate => cleanSlate,
    LiftIQTheme.shadcnDark => shadcnDark,
  };
}

// ============================================================================
// APP THEME CLASS
// ============================================================================

/// App theme configuration.
///
/// Provides themed [ThemeData] for each of the 6 LiftIQ themes.
///
/// ## Usage
/// ```dart
/// MaterialApp(
///   theme: AppTheme.forTheme(LiftIQTheme.midnightSurge),
/// )
/// ```
abstract final class AppTheme {
  /// Gets the [ThemeData] for the specified theme.
  static ThemeData forTheme(LiftIQTheme theme) => switch (theme) {
    LiftIQTheme.midnightSurge => midnightSurge,
    LiftIQTheme.warmLift => warmLift,
    LiftIQTheme.ironBrutalist => ironBrutalist,
    LiftIQTheme.neonGym => neonGym,
    LiftIQTheme.cleanSlate => cleanSlate,
    LiftIQTheme.shadcnDark => shadcnDark,
  };

  /// Legacy light theme (maps to Clean Slate).
  static ThemeData get light => cleanSlate;

  /// Legacy dark theme (maps to Shadcn Dark).
  static ThemeData get dark => shadcnDark;

  // ==========================================================================
  // THEME 1: MIDNIGHT SURGE
  // ==========================================================================

  /// Midnight Surge theme.
  ///
  /// Dark theme with electric cyan and purple accents.
  /// Minimalist, data-forward, subtle borders.
  static ThemeData get midnightSurge {
    const config = ThemeConfigs.midnightSurge;

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: MidnightSurgeColors.primary,
      onPrimary: MidnightSurgeColors.onPrimary,
      secondary: MidnightSurgeColors.secondary,
      onSecondary: MidnightSurgeColors.onSecondary,
      error: MidnightSurgeColors.error,
      onError: Colors.white,
      surface: MidnightSurgeColors.surface,
      onSurface: MidnightSurgeColors.textPrimary,
      surfaceContainerHighest: MidnightSurgeColors.surfaceContainer,
      outline: MidnightSurgeColors.outline,
      outlineVariant: MidnightSurgeColors.outline.withValues(alpha: 0.5),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      config: config,
      backgroundColor: MidnightSurgeColors.background,
      textSecondary: MidnightSurgeColors.textSecondary,
      successColor: MidnightSurgeColors.success,
    );
  }

  // ==========================================================================
  // THEME 2: WARM LIFT
  // ==========================================================================

  /// Warm Lift theme.
  ///
  /// Light theme with coral orange and peach accents.
  /// Rounded, friendly design with soft shadows.
  static ThemeData get warmLift {
    const config = ThemeConfigs.warmLift;

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: WarmLiftColors.primary,
      onPrimary: WarmLiftColors.onPrimary,
      secondary: WarmLiftColors.secondary,
      onSecondary: WarmLiftColors.onSecondary,
      error: WarmLiftColors.error,
      onError: Colors.white,
      surface: WarmLiftColors.surface,
      onSurface: WarmLiftColors.textPrimary,
      surfaceContainerHighest: WarmLiftColors.surfaceContainer,
      outline: WarmLiftColors.outline,
      outlineVariant: WarmLiftColors.outline.withValues(alpha: 0.5),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      config: config,
      backgroundColor: WarmLiftColors.background,
      textSecondary: WarmLiftColors.textSecondary,
      successColor: WarmLiftColors.success,
    );
  }

  // ==========================================================================
  // THEME 3: IRON BRUTALIST
  // ==========================================================================

  /// Iron Brutalist theme.
  ///
  /// High contrast with bold red and black accents.
  /// Sharp corners, thick borders, no shadows.
  static ThemeData get ironBrutalist {
    const config = ThemeConfigs.ironBrutalist;

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: IronBrutalistColors.primary,
      onPrimary: IronBrutalistColors.onPrimary,
      secondary: IronBrutalistColors.secondary,
      onSecondary: IronBrutalistColors.onSecondary,
      error: IronBrutalistColors.error,
      onError: Colors.white,
      surface: IronBrutalistColors.surface,
      onSurface: IronBrutalistColors.textPrimary,
      surfaceContainerHighest: IronBrutalistColors.surfaceContainer,
      outline: IronBrutalistColors.outline,
      outlineVariant: IronBrutalistColors.outline.withValues(alpha: 0.3),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      config: config,
      backgroundColor: IronBrutalistColors.background,
      textSecondary: IronBrutalistColors.textSecondary,
      successColor: IronBrutalistColors.success,
    );
  }

  // ==========================================================================
  // THEME 4: NEON GYM
  // ==========================================================================

  /// Neon Gym theme.
  ///
  /// Dark retro-futuristic with hot pink and cyan.
  /// Subtle glows, rounded corners, neon aesthetic.
  static ThemeData get neonGym {
    const config = ThemeConfigs.neonGym;

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: NeonGymColors.primary,
      onPrimary: NeonGymColors.onPrimary,
      secondary: NeonGymColors.secondary,
      onSecondary: NeonGymColors.onSecondary,
      error: NeonGymColors.error,
      onError: Colors.white,
      surface: NeonGymColors.surface,
      onSurface: NeonGymColors.textPrimary,
      surfaceContainerHighest: NeonGymColors.surfaceContainer,
      outline: NeonGymColors.outline,
      outlineVariant: NeonGymColors.outline.withValues(alpha: 0.5),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      config: config,
      backgroundColor: NeonGymColors.background,
      textSecondary: NeonGymColors.textSecondary,
      successColor: NeonGymColors.success,
    );
  }

  // ==========================================================================
  // THEME 5: CLEAN SLATE
  // ==========================================================================

  /// Clean Slate theme.
  ///
  /// Minimal light theme with slate and subtle lime.
  /// Lots of whitespace, very subtle shadows.
  static ThemeData get cleanSlate {
    const config = ThemeConfigs.cleanSlate;

    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: CleanSlateColors.primary,
      onPrimary: CleanSlateColors.onPrimary,
      secondary: CleanSlateColors.secondary,
      onSecondary: CleanSlateColors.onSecondary,
      error: CleanSlateColors.error,
      onError: Colors.white,
      surface: CleanSlateColors.surface,
      onSurface: CleanSlateColors.textPrimary,
      surfaceContainerHighest: CleanSlateColors.surfaceContainer,
      outline: CleanSlateColors.outline,
      outlineVariant: CleanSlateColors.outline.withValues(alpha: 0.5),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      config: config,
      backgroundColor: CleanSlateColors.background,
      textSecondary: CleanSlateColors.textSecondary,
      successColor: CleanSlateColors.success,
    );
  }

  // ==========================================================================
  // THEME 6: SHADCN DARK
  // ==========================================================================

  /// Shadcn Dark theme.
  ///
  /// Minimalist dark theme inspired by shadcn/ui.
  /// Uses zinc color palette with subtle borders.
  static ThemeData get shadcnDark {
    const config = ThemeConfigs.shadcnDark;

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: ShadcnDarkColors.primary,
      onPrimary: ShadcnDarkColors.onPrimary,
      secondary: ShadcnDarkColors.secondary,
      onSecondary: ShadcnDarkColors.onSecondary,
      error: ShadcnDarkColors.error,
      onError: Colors.white,
      surface: ShadcnDarkColors.surface,
      onSurface: ShadcnDarkColors.textPrimary,
      surfaceContainerHighest: ShadcnDarkColors.surfaceContainer,
      outline: ShadcnDarkColors.outline,
      outlineVariant: ShadcnDarkColors.outline.withValues(alpha: 0.5),
    );

    return _buildTheme(
      colorScheme: colorScheme,
      config: config,
      backgroundColor: ShadcnDarkColors.background,
      textSecondary: ShadcnDarkColors.textSecondary,
      successColor: ShadcnDarkColors.success,
    );
  }

  // ==========================================================================
  // THEME BUILDER
  // ==========================================================================

  /// Builds a complete [ThemeData] from the given parameters.
  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required ThemeConfig config,
    required Color backgroundColor,
    required Color textSecondary,
    required Color successColor,
  }) {
    final textTheme = _buildTextTheme(colorScheme, textSecondary, config);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      scaffoldBackgroundColor: backgroundColor,

      // Typography
      textTheme: textTheme,

      // App Bar
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: config.cardElevation,
        backgroundColor: backgroundColor,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: config.headingWeight,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        elevation: config.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.cardBorderRadius),
          side: config.borderWidth > 0
              ? BorderSide(
                  color: colorScheme.outline,
                  width: config.borderWidth,
                )
              : BorderSide.none,
        ),
        color: colorScheme.surface,
      ),

      // Elevated Buttons (primary actions)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          elevation: config.buttonElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.buttonBorderRadius),
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: config.headingWeight,
            letterSpacing: config.uppercaseHeadings ? 1.0 : 0.0,
          ),
        ),
      ),

      // Filled Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.buttonBorderRadius),
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: config.headingWeight,
            letterSpacing: config.uppercaseHeadings ? 1.0 : 0.0,
          ),
        ),
      ),

      // Outlined Buttons (secondary actions)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.buttonBorderRadius),
          ),
          side: BorderSide(
            color: colorScheme.outline,
            width: config.borderWidth.clamp(1.0, 3.0),
          ),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: config.headingWeight,
            letterSpacing: config.uppercaseHeadings ? 1.0 : 0.0,
          ),
        ),
      ),

      // Text Buttons (tertiary actions)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: config.bodyWeight,
          ),
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.borderRadius),
          borderSide: config.borderWidth > 0
              ? BorderSide(color: colorScheme.outline, width: config.borderWidth)
              : BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.borderRadius),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.5),
            width: config.borderWidth.clamp(1.0, 2.0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.borderRadius),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: config.borderWidth.clamp(1.0, 2.0) + 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.borderRadius),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: config.borderWidth.clamp(1.0, 2.0),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: config.buttonElevation + 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.buttonBorderRadius + 4),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: textSecondary,
        elevation: config.cardElevation + 4,
      ),

      // Navigation Bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.2),
        elevation: config.cardElevation,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.borderRadius),
        ),
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.5),
        thickness: config.borderWidth.clamp(0.5, 1.0),
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.borderRadius),
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.borderRadius),
          side: BorderSide(
            color: colorScheme.outline,
            width: config.borderWidth.clamp(0.5, 1.0),
          ),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.cardBorderRadius),
        ),
        backgroundColor: colorScheme.surface,
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(config.cardBorderRadius),
          ),
        ),
        backgroundColor: colorScheme.surface,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withValues(alpha: 0.5);
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.surfaceContainerHighest,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withValues(alpha: 0.2),
      ),

      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
      ),

      // Tab Bar
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: textSecondary,
        indicatorColor: colorScheme.primary,
        dividerColor: colorScheme.outline.withValues(alpha: 0.3),
      ),

      // Extensions for custom theme data
      extensions: [
        LiftIQThemeExtension(
          successColor: successColor,
          config: config,
        ),
      ],
    );
  }

  /// Builds the text theme for the app.
  static TextTheme _buildTextTheme(
    ColorScheme colorScheme,
    Color textSecondary,
    ThemeConfig config,
  ) {
    return TextTheme(
      // Display styles (large headers)
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: config.headingWeight,
        letterSpacing: -0.25,
        color: colorScheme.onSurface,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: config.headingWeight,
        color: colorScheme.onSurface,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: config.headingWeight,
        color: colorScheme.onSurface,
      ),

      // Headline styles (section headers)
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: config.headingWeight,
        color: colorScheme.onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: config.headingWeight,
        color: colorScheme.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: config.headingWeight,
        color: colorScheme.onSurface,
      ),

      // Title styles (card titles, list items)
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: config.headingWeight,
        color: colorScheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: config.headingWeight,
        letterSpacing: 0.15,
        color: colorScheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: config.headingWeight,
        letterSpacing: 0.1,
        color: colorScheme.onSurface,
      ),

      // Body styles (main content)
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: config.bodyWeight,
        letterSpacing: 0.5,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: config.bodyWeight,
        letterSpacing: 0.25,
        color: colorScheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: config.bodyWeight,
        letterSpacing: 0.4,
        color: textSecondary,
      ),

      // Label styles (buttons, tabs)
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: config.headingWeight,
        letterSpacing: config.uppercaseHeadings ? 1.0 : 0.1,
        color: colorScheme.onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: config.headingWeight,
        letterSpacing: 0.5,
        color: colorScheme.onSurface,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: config.headingWeight,
        letterSpacing: 0.5,
        color: textSecondary,
      ),
    );
  }
}

// ============================================================================
// THEME EXTENSION
// ============================================================================

/// Custom theme extension for LiftIQ-specific properties.
///
/// Access via `Theme.of(context).extension<LiftIQThemeExtension>()`.
class LiftIQThemeExtension extends ThemeExtension<LiftIQThemeExtension> {
  final Color successColor;
  final ThemeConfig config;

  const LiftIQThemeExtension({
    required this.successColor,
    required this.config,
  });

  @override
  LiftIQThemeExtension copyWith({
    Color? successColor,
    ThemeConfig? config,
  }) {
    return LiftIQThemeExtension(
      successColor: successColor ?? this.successColor,
      config: config ?? this.config,
    );
  }

  @override
  LiftIQThemeExtension lerp(ThemeExtension<LiftIQThemeExtension>? other, double t) {
    if (other is! LiftIQThemeExtension) {
      return this;
    }
    return LiftIQThemeExtension(
      successColor: Color.lerp(successColor, other.successColor, t)!,
      config: t < 0.5 ? config : other.config,
    );
  }
}

// ============================================================================
// CONTEXT EXTENSIONS
// ============================================================================

/// Extension on BuildContext for easy theme access.
///
/// Usage:
/// ```dart
/// final colors = context.colors;
/// final textTheme = context.textTheme;
/// final liftiqTheme = context.liftiqTheme;
/// ```
extension LiftIQBuildContextTheme on BuildContext {
  /// Gets the current color scheme.
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Gets the current text theme.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Gets the current theme data.
  ThemeData get theme => Theme.of(this);

  /// Whether the current theme is dark mode.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Gets the LiftIQ theme extension.
  LiftIQThemeExtension? get liftiqTheme =>
      Theme.of(this).extension<LiftIQThemeExtension>();

  /// Gets the success color from the theme.
  Color get successColor => liftiqTheme?.successColor ?? Colors.green;

  /// Gets the theme config.
  ThemeConfig get themeConfig =>
      liftiqTheme?.config ?? ThemeConfigs.midnightSurge;
}
