import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light(Color seed) => _buildTheme(
        seed,
        brightness: Brightness.light,
        gradient: const [Color(0xFFFFE1EA), Color(0xFFFFC7D1)],
      );

  static ThemeData dark(Color seed) => _buildTheme(
        seed,
        brightness: Brightness.dark,
        gradient: const [Color(0xFF1C1A22), Color(0xFF261F2A)],
      );

  static ThemeData _buildTheme(
    Color seed, {
    required Brightness brightness,
    required List<Color> gradient,
  }) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );

    final poppins = GoogleFonts.poppinsTextTheme(base.textTheme);
    final fallbackFont = GoogleFonts.cairo().fontFamily ?? 'Cairo';
    final textTheme = poppins.apply(
      fontFamilyFallback: [fallbackFont],
    );
    final primaryTextTheme = GoogleFonts.cairoTextTheme(base.primaryTextTheme);

    final tokens = JewelThemeTokens(
      lightGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: gradient,
      ),
      darkGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: brightness == Brightness.dark
            ? gradient
            : const [Color(0xFF1C1A22), Color(0xFF261F2A)],
      ),
      cardRadius: 26,
      pillRadius: 18,
      chipRadius: 14,
      glassBlurSigma: 16,
      ctaBlack: const Color(0xFF0F0F0F),
      softShadow: const [
        BoxShadow(color: Color(0x1F000000), blurRadius: 18, offset: Offset(0, 8)),
      ],
      pricePillBackground: const Color(0xFFFFFFE6),
      pricePillForeground: const Color(0xFF111111),
      brandAvatarBg: const Color(0xFFFFFFFF),
      brandAvatarFg: const Color(0xFF111111),
    );

    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(tokens.cardRadius),
    );

    return base.copyWith(
      colorScheme: colorScheme,
      textTheme: textTheme,
      primaryTextTheme: primaryTextTheme,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        systemOverlayStyle:
            brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardTheme(
        shape: cardShape,
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        color: colorScheme.surface.withOpacity(brightness == Brightness.dark ? 0.85 : 0.82),
        surfaceTintColor: Colors.transparent,
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.chipRadius)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        selectedColor: colorScheme.primary.withOpacity(0.16),
        backgroundColor: colorScheme.surfaceVariant.withOpacity(0.4),
        labelStyle: textTheme.labelLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.disabled)) {
              return colorScheme.onSurface.withOpacity(0.12);
            }
            return tokens.ctaBlack;
          }),
          foregroundColor: const MaterialStatePropertyAll(Colors.white),
          minimumSize: const MaterialStatePropertyAll(Size.fromHeight(52)),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.pillRadius)),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.pillRadius)),
          ),
          side: MaterialStateProperty.resolveWith((states) {
            final color = states.contains(MaterialState.disabled)
                ? colorScheme.outlineVariant
                : colorScheme.primary;
            return BorderSide(color: color.withOpacity(0.6));
          }),
          padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.pillRadius)),
          ),
          padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: colorScheme.primary.withOpacity(0.12),
        elevation: 0,
        height: 72,
        labelTextStyle: MaterialStatePropertyAll(
          textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      dividerColor: colorScheme.outline.withOpacity(0.2),
      extensions: [tokens],
    );
  }
}

class JewelThemeTokens extends ThemeExtension<JewelThemeTokens> {
  const JewelThemeTokens({
    required this.lightGradient,
    required this.darkGradient,
    required this.cardRadius,
    required this.pillRadius,
    required this.chipRadius,
    required this.glassBlurSigma,
    required this.ctaBlack,
    required this.softShadow,
    required this.pricePillBackground,
    required this.pricePillForeground,
    required this.brandAvatarBg,
    required this.brandAvatarFg,
  });

  final LinearGradient lightGradient;
  final LinearGradient darkGradient;
  final double cardRadius;
  final double pillRadius;
  final double chipRadius;
  final double glassBlurSigma;
  final Color ctaBlack;
  final List<BoxShadow> softShadow;
  final Color pricePillBackground;
  final Color pricePillForeground;
  final Color brandAvatarBg;
  final Color brandAvatarFg;

  @override
  JewelThemeTokens copyWith({
    LinearGradient? lightGradient,
    LinearGradient? darkGradient,
    double? cardRadius,
    double? pillRadius,
    double? chipRadius,
    double? glassBlurSigma,
    Color? ctaBlack,
    List<BoxShadow>? softShadow,
    Color? pricePillBackground,
    Color? pricePillForeground,
    Color? brandAvatarBg,
    Color? brandAvatarFg,
  }) {
    return JewelThemeTokens(
      lightGradient: lightGradient ?? this.lightGradient,
      darkGradient: darkGradient ?? this.darkGradient,
      cardRadius: cardRadius ?? this.cardRadius,
      pillRadius: pillRadius ?? this.pillRadius,
      chipRadius: chipRadius ?? this.chipRadius,
      glassBlurSigma: glassBlurSigma ?? this.glassBlurSigma,
      ctaBlack: ctaBlack ?? this.ctaBlack,
      softShadow: softShadow ?? this.softShadow,
      pricePillBackground: pricePillBackground ?? this.pricePillBackground,
      pricePillForeground: pricePillForeground ?? this.pricePillForeground,
      brandAvatarBg: brandAvatarBg ?? this.brandAvatarBg,
      brandAvatarFg: brandAvatarFg ?? this.brandAvatarFg,
    );
  }

  @override
  ThemeExtension<JewelThemeTokens> lerp(covariant ThemeExtension<JewelThemeTokens>? other, double t) {
    if (other is! JewelThemeTokens) return this;
    return JewelThemeTokens(
      lightGradient: LinearGradient.lerp(lightGradient, other.lightGradient, t) ?? lightGradient,
      darkGradient: LinearGradient.lerp(darkGradient, other.darkGradient, t) ?? darkGradient,
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t) ?? cardRadius,
      pillRadius: lerpDouble(pillRadius, other.pillRadius, t) ?? pillRadius,
      chipRadius: lerpDouble(chipRadius, other.chipRadius, t) ?? chipRadius,
      glassBlurSigma: lerpDouble(glassBlurSigma, other.glassBlurSigma, t) ?? glassBlurSigma,
      ctaBlack: Color.lerp(ctaBlack, other.ctaBlack, t) ?? ctaBlack,
      softShadow: BoxShadow.lerpList(softShadow, other.softShadow, t) ?? softShadow,
      pricePillBackground:
          Color.lerp(pricePillBackground, other.pricePillBackground, t) ?? pricePillBackground,
      pricePillForeground:
          Color.lerp(pricePillForeground, other.pricePillForeground, t) ?? pricePillForeground,
      brandAvatarBg: Color.lerp(brandAvatarBg, other.brandAvatarBg, t) ?? brandAvatarBg,
      brandAvatarFg: Color.lerp(brandAvatarFg, other.brandAvatarFg, t) ?? brandAvatarFg,
    );
  }
}
