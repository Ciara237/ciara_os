import 'package:ciaraos/models/enums/domain.dart';
import 'package:flutter/material.dart';

/// Design tokens extracted from Stitch Ciara OS HTML + DESIGN.md.
abstract final class AppColors {
  // --- Dark surfaces ---
  static const Color darkBackground = Color(0xFF081425);
  static const Color darkSurface = Color(0xFF081425);
  static const Color darkSurfaceDim = Color(0xFF081425);
  static const Color darkSurfaceBright = Color(0xFF2F3A4C);
  static const Color darkSurfaceContainerLowest = Color(0xFF040E1F);
  static const Color darkSurfaceContainerLow = Color(0xFF111C2D);
  static const Color darkSurfaceContainer = Color(0xFF152031);
  static const Color darkSurfaceContainerHigh = Color(0xFF1F2A3C);
  static const Color darkSurfaceContainerHighest = Color(0xFF2A3548);
  static const Color darkSurfaceVariant = Color(0xFF2A3548);

  // --- Dark text & borders ---
  static const Color darkOnBackground = Color(0xFFD8E3FB);
  static const Color darkOnSurface = Color(0xFFD8E3FB);
  static const Color darkOnSurfaceVariant = Color(0xFFC5C6CD);
  static const Color darkOutline = Color(0xFF8E9197);
  static const Color darkOutlineVariant = Color(0xFF44474C);
  static const Color darkBorderSubtle = Color(0x3344474C); // outline-variant @ 20%

  // --- Dark accent (primary / secondary / tertiary) ---
  static const Color darkPrimary = Color(0xFFB9C7E0);
  static const Color darkOnPrimary = Color(0xFF233144);
  static const Color darkPrimaryContainer = Color(0xFF334155);
  static const Color darkOnPrimaryContainer = Color(0xFF9EADC5);
  static const Color darkPrimaryFixed = Color(0xFFD5E3FD);
  static const Color darkPrimaryFixedDim = Color(0xFFB9C7E0);
  static const Color darkSecondary = Color(0xFFB7C8E1);
  static const Color darkOnSecondary = Color(0xFF213145);
  static const Color darkSecondaryContainer = Color(0xFF3A4A5F);
  static const Color darkOnSecondaryContainer = Color(0xFFA9BAD3);
  static const Color darkTertiary = Color(0xFFDFC299);
  static const Color darkOnTertiary = Color(0xFF3F2D10);
  static const Color darkTertiaryContainer = Color(0xFF503D1E);
  static const Color darkOnTertiaryContainer = Color(0xFFC3A881);
  static const Color darkError = Color(0xFFFFB4AB);
  static const Color darkOnError = Color(0xFF690005);
  static const Color darkErrorContainer = Color(0xFF93000A);
  static const Color darkOnErrorContainer = Color(0xFFFFDAD6);
  static const Color darkInverseSurface = Color(0xFFD8E3FB);
  static const Color darkInverseOnSurface = Color(0xFF263143);
  static const Color darkInversePrimary = Color(0xFF515F74);
  static const Color darkSurfaceTint = Color(0xFFB9C7E0);

  // --- Light surfaces (derived from DESIGN.md slate scale + M3 inverse roles) ---
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFF8FAFC);
  static const Color lightSurfaceDim = Color(0xFFE2E8F0);
  static const Color lightSurfaceBright = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFF1F5F9);
  static const Color lightSurfaceContainer = Color(0xFFE2E8F0);
  static const Color lightSurfaceContainerHigh = Color(0xFFCBD5E1);
  static const Color lightSurfaceContainerHighest = Color(0xFF94A3B8);
  static const Color lightSurfaceVariant = Color(0xFFE2E8F0);

  // --- Light text & borders ---
  static const Color lightOnBackground = Color(0xFF0F172A);
  static const Color lightOnSurface = Color(0xFF0F172A);
  static const Color lightOnSurfaceVariant = Color(0xFF475569);
  static const Color lightOutline = Color(0xFF64748B);
  static const Color lightOutlineVariant = Color(0xFFCBD5E1);
  static const Color lightBorderSubtle = Color(0x33CBD5E1);

  // --- Light accent ---
  static const Color lightPrimary = Color(0xFF515F74);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFD5E3FD);
  static const Color lightOnPrimaryContainer = Color(0xFF0D1C2F);
  static const Color lightPrimaryFixed = Color(0xFFD5E3FD);
  static const Color lightPrimaryFixedDim = Color(0xFFB9C7E0);
  static const Color lightSecondary = Color(0xFF38485D);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightSecondaryContainer = Color(0xFFD3E4FE);
  static const Color lightOnSecondaryContainer = Color(0xFF0B1C30);
  static const Color lightTertiary = Color(0xFF8B6914);
  static const Color lightOnTertiary = Color(0xFFFFFFFF);
  static const Color lightTertiaryContainer = Color(0xFFFCDEB3);
  static const Color lightOnTertiaryContainer = Color(0xFF281901);
  static const Color lightError = Color(0xFFBA1A1A);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFFFDAD6);
  static const Color lightOnErrorContainer = Color(0xFF690005);
  static const Color lightInverseSurface = Color(0xFF263143);
  static const Color lightInverseOnSurface = Color(0xFFD8E3FB);
  static const Color lightInversePrimary = Color(0xFFB9C7E0);
  static const Color lightSurfaceTint = Color(0xFF515F74);

  /// Domain accent colors — from `onboarding_domains_ciara_os_dark/code.html`.
  static const Map<Domain, Color> domainColors = {
    Domain.engineering: Color(0xFF3B82F6),
    Domain.security: Color(0xFFEF4444),
    Domain.opportunities: Color(0xFF10B981),
    Domain.builder: Color(0xFF8B5CF6),
    Domain.other: Color(0xFF64748B),
  };

  /// Deeper domain shades for light backgrounds (same hues, higher contrast).
  static const Map<Domain, Color> domainColorsLight = {
    Domain.engineering: Color(0xFF2563EB),
    Domain.security: Color(0xFFDC2626),
    Domain.opportunities: Color(0xFF059669),
    Domain.builder: Color(0xFF7C3AED),
    Domain.other: Color(0xFF475569),
  };

  static const ColorScheme darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: darkPrimary,
    onPrimary: darkOnPrimary,
    primaryContainer: darkPrimaryContainer,
    onPrimaryContainer: darkOnPrimaryContainer,
    primaryFixed: darkPrimaryFixed,
    primaryFixedDim: darkPrimaryFixedDim,
    onPrimaryFixed: Color(0xFF0D1C2F),
    onPrimaryFixedVariant: Color(0xFF3A485C),
    secondary: darkSecondary,
    onSecondary: darkOnSecondary,
    secondaryContainer: darkSecondaryContainer,
    onSecondaryContainer: darkOnSecondaryContainer,
    secondaryFixed: Color(0xFFD3E4FE),
    secondaryFixedDim: Color(0xFFB7C8E1),
    onSecondaryFixed: Color(0xFF0B1C30),
    onSecondaryFixedVariant: Color(0xFF38485D),
    tertiary: darkTertiary,
    onTertiary: darkOnTertiary,
    tertiaryContainer: darkTertiaryContainer,
    onTertiaryContainer: darkOnTertiaryContainer,
    tertiaryFixed: Color(0xFFFCDEB3),
    tertiaryFixedDim: Color(0xFFDFC299),
    onTertiaryFixed: Color(0xFF281901),
    onTertiaryFixedVariant: Color(0xFF574424),
    error: darkError,
    onError: darkOnError,
    errorContainer: darkErrorContainer,
    onErrorContainer: darkOnErrorContainer,
    surface: darkSurface,
    onSurface: darkOnSurface,
    surfaceDim: darkSurfaceDim,
    surfaceBright: darkSurfaceBright,
    surfaceContainerLowest: darkSurfaceContainerLowest,
    surfaceContainerLow: darkSurfaceContainerLow,
    surfaceContainer: darkSurfaceContainer,
    surfaceContainerHigh: darkSurfaceContainerHigh,
    surfaceContainerHighest: darkSurfaceContainerHighest,
    onSurfaceVariant: darkOnSurfaceVariant,
    outline: darkOutline,
    outlineVariant: darkOutlineVariant,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: darkInverseSurface,
    onInverseSurface: darkInverseOnSurface,
    inversePrimary: darkInversePrimary,
    surfaceTint: darkSurfaceTint,
  );

  static const ColorScheme lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: lightPrimary,
    onPrimary: lightOnPrimary,
    primaryContainer: lightPrimaryContainer,
    onPrimaryContainer: lightOnPrimaryContainer,
    primaryFixed: lightPrimaryFixed,
    primaryFixedDim: lightPrimaryFixedDim,
    onPrimaryFixed: Color(0xFF0D1C2F),
    onPrimaryFixedVariant: Color(0xFF3A485C),
    secondary: lightSecondary,
    onSecondary: lightOnSecondary,
    secondaryContainer: lightSecondaryContainer,
    onSecondaryContainer: lightOnSecondaryContainer,
    secondaryFixed: Color(0xFFD3E4FE),
    secondaryFixedDim: Color(0xFFB7C8E1),
    onSecondaryFixed: Color(0xFF0B1C30),
    onSecondaryFixedVariant: Color(0xFF38485D),
    tertiary: lightTertiary,
    onTertiary: lightOnTertiary,
    tertiaryContainer: lightTertiaryContainer,
    onTertiaryContainer: lightOnTertiaryContainer,
    tertiaryFixed: Color(0xFFFCDEB3),
    tertiaryFixedDim: Color(0xFFDFC299),
    onTertiaryFixed: Color(0xFF281901),
    onTertiaryFixedVariant: Color(0xFF574424),
    error: lightError,
    onError: lightOnError,
    errorContainer: lightErrorContainer,
    onErrorContainer: lightOnErrorContainer,
    surface: lightSurface,
    onSurface: lightOnSurface,
    surfaceDim: lightSurfaceDim,
    surfaceBright: lightSurfaceBright,
    surfaceContainerLowest: lightSurfaceContainerLowest,
    surfaceContainerLow: lightSurfaceContainerLow,
    surfaceContainer: lightSurfaceContainer,
    surfaceContainerHigh: lightSurfaceContainerHigh,
    surfaceContainerHighest: lightSurfaceContainerHighest,
    onSurfaceVariant: lightOnSurfaceVariant,
    outline: lightOutline,
    outlineVariant: lightOutlineVariant,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: lightInverseSurface,
    onInverseSurface: lightInverseOnSurface,
    inversePrimary: lightInversePrimary,
    surfaceTint: lightSurfaceTint,
  );
}
