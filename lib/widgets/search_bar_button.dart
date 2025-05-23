// lib/widgets/search_bar_button.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchBarButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  const SearchBarButton({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
  });

  @override
  State<SearchBarButton> createState() => _SearchBarButtonState();
}

class _SearchBarButtonState extends State<SearchBarButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    final Color backgroundColor = _isHovered
        ? theme.colorScheme.onSurface.withOpacity(0.1)
        : theme.colorScheme.surface
            .withOpacity(isDark ? 0.3 : 0.5); // Subtle background

    final Color contentColor = _isHovered
        ? theme.colorScheme.primary
        : theme.textTheme.bodyMedium!.color!.withOpacity(0.7);

    return Material(
      color: Colors.transparent, // Handled by InkWell container
      child: InkWell(
        onTap: widget.onTap,
        onHover: (hovering) {
          setState(() {
            _isHovered = hovering;
          });
        },
        borderRadius: BorderRadius.circular(20), // Pill shape
        splashColor: theme.colorScheme.primary.withOpacity(0.1),
        highlightColor: theme.colorScheme.primary.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20), // Pill shape
              border: Border.all(
                  color: _isHovered
                      ? theme.colorScheme.primary.withOpacity(0.5)
                      : theme.dividerColor.withOpacity(0.3),
                  width: 0.5)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: contentColor,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                widget.text,
                style: GoogleFonts.roboto(
                  // Or your app's button font
                  color: contentColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
