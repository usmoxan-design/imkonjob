import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Centralized typography.
///
/// Three-font system:
///  • Poppins      → headings, titles, names  (professional, modern)
///  • Space Grotesk → numbers, prices, stats  (techy, data-forward)
///  • Nunito        → body, descriptions, labels (friendly, readable)
class AppTextStyles {
  AppTextStyles._();

  // ── Poppins — Headings & titles ──────────────────────────────────────────

  static TextStyle displayLarge({Color? color}) => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: -0.5,
      );

  static TextStyle heading1({Color? color}) => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -0.3,
      );

  static TextStyle heading2({Color? color}) => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle heading3({Color? color}) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      );

  /// Used for AppBar titles
  static TextStyle appBar({Color? color}) => GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: color,
      );

  /// Card / list item main title
  static TextStyle cardTitle({Color? color}) => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color,
      );

  /// Provider / person name
  static TextStyle name({Color? color}) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: color,
      );

  /// Section label inside a card
  static TextStyle sectionLabel({Color? color}) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
      );

  // ── Space Grotesk — Numbers, prices & stats ──────────────────────────────

  /// Large price display  e.g. "120 000 so'm"
  static TextStyle priceLarge({Color? color}) => GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.primary,
        letterSpacing: -0.5,
      );

  /// Inline price inside a card
  static TextStyle priceInline({Color? color}) => GoogleFonts.spaceGrotesk(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.primary,
      );

  /// Stat number (dashboard, profile)
  static TextStyle stat({Color? color, double size = 24}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: -0.5,
      );

  /// Rating number  "4.8 ★"
  static TextStyle rating({Color? color}) => GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: color,
      );

  /// Phone number display
  static TextStyle phone({Color? color}) => GoogleFonts.spaceGrotesk(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.primary,
        letterSpacing: 1,
      );

  /// Generic number / counter
  static TextStyle number({
    double size = 16,
    Color? color,
    FontWeight weight = FontWeight.w700,
  }) =>
      GoogleFonts.spaceGrotesk(fontSize: size, fontWeight: weight, color: color);

  // ── Nunito — Body text & labels (kept for readability) ───────────────────

  static TextStyle body({
    double size = 14,
    Color? color,
    FontWeight weight = FontWeight.w400,
    double? height,
  }) =>
      GoogleFonts.nunito(
          fontSize: size, fontWeight: weight, color: color, height: height);

  static TextStyle label({Color? color, double size = 13}) =>
      GoogleFonts.nunito(
          fontSize: size, fontWeight: FontWeight.w600, color: color);

  static TextStyle hint({Color? color}) =>
      GoogleFonts.nunito(fontSize: 14, color: color ?? AppColors.textHint);

  static TextStyle caption({Color? color}) =>
      GoogleFonts.nunito(fontSize: 12, color: color);

  static TextStyle button({Color? color}) =>
      GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, color: color);
}
