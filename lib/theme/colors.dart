// lib/theme/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // --- Simple Search Purple Theme ---

  // Primary Colors
  static const Color primaryPurple =
      Color(0xFFB39DDB); // Light, friendly purple (Material Deep Purple 200)
  static const Color primaryPurpleDark =
      Color(0xFF7E57C2); // A richer purple (Material Deep Purple 300)
  static const Color primaryPurpleLight =
      Color(0xFFE1BEE7); // Very soft purple/lilac (Material Purple 100)

  // Accent Color
  // A soft gold/yellow can complement purple well and add a touch of warmth/positivity.
  // Or a contrasting teal for a more modern feel. Let's try a soft teal.
  static const Color accentTeal = Color(0xFF80CBC4); // Material Teal 200
  static const Color accentTealDark = Color(0xFF4DB6AC); // Material Teal 300

  // Background Colors
  static const Color backgroundLight =
      Color(0xFFFDFCFE); // Very light, almost white with a hint of purple
  static const Color backgroundDark =
      Color(0xFF2C2A2E); // Dark grey with a hint of purple

  // Card Colors
  static const Color cardLight = Colors.white;
  static const Color cardDark =
      Color(0xFF3E3C42); // Darker than backgroundDark for cards

  // Text Colors
  static const Color textLightPrimary =
      Color(0xFF212121); // Dark grey for text on light backgrounds
  static const Color textLightSecondary = Color(0xFF5F6368); // Lighter grey
  static const Color textDarkPrimary =
      Color(0xFFE8E8E8); // Light grey for text on dark backgrounds
  static const Color textDarkSecondary = Color(0xFFB0B0B0);

  // Common UI Elements (can use theme colors or specific ones)
  static const Color iconColorLight = Color(0xFF5F6368);
  static const Color iconColorDark = Color(0xFFB0B0B0);

  static const Color dividerColorLight =
      Color(0xFFD1C4E9); // Light purple for dividers
  static const Color dividerColorDark =
      Color(0xFF4527A0); // Darker purple for dividers

  // --- Old Colors (from previous perplexity_clone theme for reference, can be removed) ---
  // static const background = Color.fromRGBO(25, 26, 26, 1);
  // static const sideNav = Color.fromRGBO(32, 34, 34, 1);
  // static const searchBar = Color.fromRGBO(32, 34, 34, 1);
  // static const searchBarBorder = Color.fromRGBO(60, 63, 64, 1);
  // static const iconGrey = Color(0xFF909090);
  // static const textGrey = Color(0xFFAAAAAA);
  // static const footerGrey = Color(0xFF737373);
  // static const proButton = Color.fromRGBO(47, 48, 47, 1);
  // static const cardColor = Color(0xFF262626);
  // static const submitButton = Color.fromRGBO(27, 185, 206, 1);
  static const whiteColor = Colors.white; // Still useful
}
