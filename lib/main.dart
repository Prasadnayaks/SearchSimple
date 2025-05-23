// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:searchsimple/services/chat_web_service.dart'; // Adjust path if your package name changed
import 'package:searchsimple/pages/home_page.dart';
import 'package:searchsimple/theme/colors.dart'; // Your updated AppColors

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // It's good practice to call connect only once.
  // ChatWebService now has internal guards against multiple inits if connect is called elsewhere too.
  await ChatWebService().connect();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Base text themes (can be shared for light and dark)
    final TextTheme baseTextTheme =
        Theme.of(context).textTheme; // Use current context's base

    final TextTheme appPrimaryTextTheme =
        GoogleFonts.montserratTextTheme(baseTextTheme).copyWith(
      // Headlines, Titles (Montserrat - modern, clean, slightly playful)
      displayLarge: GoogleFonts.montserrat(
          textStyle: baseTextTheme.displayLarge, fontWeight: FontWeight.w700),
      displayMedium: GoogleFonts.montserrat(
          textStyle: baseTextTheme.displayMedium, fontWeight: FontWeight.w700),
      displaySmall: GoogleFonts.montserrat(
          textStyle: baseTextTheme.displaySmall, fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.montserrat(
          textStyle: baseTextTheme.headlineMedium, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.montserrat(
          textStyle: baseTextTheme.headlineSmall, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.montserrat(
          textStyle: baseTextTheme.titleLarge,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5),
      titleMedium: GoogleFonts.montserrat(
          textStyle: baseTextTheme.titleMedium, fontWeight: FontWeight.w500),
      titleSmall: GoogleFonts.montserrat(
          textStyle: baseTextTheme.titleSmall, fontWeight: FontWeight.w500),
    );

    final TextTheme appBodyTextTheme =
        GoogleFonts.robotoTextTheme(baseTextTheme).copyWith(
      // Body, Buttons, Captions (Roboto - highly readable)
      bodyLarge: GoogleFonts.roboto(
          textStyle: baseTextTheme.bodyLarge, fontSize: 16, height: 1.5),
      bodyMedium: GoogleFonts.roboto(
          textStyle: baseTextTheme.bodyMedium, fontSize: 14, height: 1.5),
      bodySmall: GoogleFonts.roboto(
          textStyle: baseTextTheme.bodySmall, fontSize: 12, height: 1.4),
      labelLarge: GoogleFonts.roboto(
          textStyle: baseTextTheme.labelLarge,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5), // For buttons
    );

    // Combine for a full text theme, giving precedence as needed
    final TextTheme combinedTextTheme = appPrimaryTextTheme.copyWith(
      bodyLarge: appBodyTextTheme.bodyLarge,
      bodyMedium: appBodyTextTheme.bodyMedium,
      bodySmall: appBodyTextTheme.bodySmall,
      labelLarge: appBodyTextTheme.labelLarge,
      labelMedium: appBodyTextTheme.labelMedium,
      labelSmall: appBodyTextTheme.labelSmall,
    );

    // --- Light Theme Definition ---
    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryPurple,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryPurple,
        onPrimary: AppColors.whiteColor, // Text/icons on primary color
        secondary: AppColors.accentTeal,
        onSecondary: Colors.black, // Text/icons on accent color
        surface: AppColors.cardLight, // Card backgrounds, dialogs
        onSurface: AppColors.textLightPrimary, // Text on cards/dialogs
        background: AppColors.backgroundLight,
        onBackground: AppColors.textLightPrimary,
        error: Colors.redAccent,
        onError: Colors.white,
      ),
      textTheme: combinedTextTheme.apply(
        bodyColor: AppColors.textLightPrimary,
        displayColor: AppColors.textLightPrimary, // For headlines
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryPurple,
        elevation: 0.5, // Subtle shadow
        iconTheme: const IconThemeData(color: AppColors.whiteColor),
        titleTextStyle: GoogleFonts.montserrat(
          color: AppColors.whiteColor,
          fontSize: 18, // Standard AppBar title size
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: AppColors.cardLight,
        surfaceTintColor:
            Colors.transparent, // To avoid M3 tinting if not desired
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardLight.withOpacity(0.7),
        hintStyle:
            TextStyle(color: AppColors.textLightSecondary.withOpacity(0.8)),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(25.0), // Consistent with ChatPage input
          borderSide:
              BorderSide(color: AppColors.dividerColorLight.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide:
              BorderSide(color: AppColors.dividerColorLight.withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide:
              const BorderSide(color: AppColors.primaryPurple, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.primaryPurpleDark, // Richer purple for buttons
          foregroundColor: AppColors.whiteColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.roboto(
              fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: 0.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)), // Pill-shaped buttons
          elevation: 2,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryPurpleDark,
              textStyle: GoogleFonts.roboto(fontWeight: FontWeight.w600))),
      iconTheme: const IconThemeData(color: AppColors.iconColorLight, size: 22),
      dividerTheme: DividerThemeData(
        color: AppColors.dividerColorLight.withOpacity(0.6),
        thickness: 0.8,
      ),
    );

    // --- Dark Theme Definition ---
    final ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      primaryColor:
          AppColors.primaryPurpleDark, // A bit more prominent in dark mode
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary:
            AppColors.primaryPurple, // Lighter purple as primary against dark
        onPrimary: AppColors.textDarkPrimary,
        secondary: AppColors.accentTeal,
        onSecondary: AppColors.textLightPrimary, // Darker text on light accent
        surface: AppColors.cardDark,
        onSurface: AppColors.textDarkPrimary,
        background: AppColors.backgroundDark,
        onBackground: AppColors.textDarkPrimary,
        error: Colors.redAccent,
        onError: Colors.black,
      ),
      textTheme: combinedTextTheme.apply(
        bodyColor: AppColors.textDarkPrimary,
        displayColor: AppColors.textDarkPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cardDark, // Dark surface for AppBar
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDarkPrimary),
        titleTextStyle: GoogleFonts.montserrat(
          color: AppColors.textDarkPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: AppColors.cardDark,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundDark
            .withOpacity(0.7), // Slightly different from card for depth
        hintStyle:
            TextStyle(color: AppColors.textDarkSecondary.withOpacity(0.8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide:
              BorderSide(color: AppColors.dividerColorDark.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide:
              BorderSide(color: AppColors.dividerColorDark.withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide:
              const BorderSide(color: AppColors.primaryPurple, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.primaryPurple, // Lighter purple for buttons on dark
          foregroundColor:
              AppColors.textLightPrimary, // Dark text on light purple button
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.roboto(
              fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: 0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          elevation: 2,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryPurple,
              textStyle: GoogleFonts.roboto(fontWeight: FontWeight.w600))),
      iconTheme: const IconThemeData(color: AppColors.iconColorDark, size: 22),
      dividerTheme: DividerThemeData(
        color: AppColors.dividerColorDark.withOpacity(0.6),
        thickness: 0.8,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Search', // Updated title
      theme: lightTheme, // Apply the light theme
      darkTheme: darkTheme, // Apply the dark theme
      themeMode: ThemeMode
          .system, // Respect system preference (or choose .light or .dark)
      home: const HomePage(),
    );
  }
}
