// lib/widgets/side_bar_button.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SideBarButton extends StatefulWidget {
  final bool isCollapsed;
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final bool
      isSelected; // To indicate if this button represents the current page/view

  const SideBarButton({
    super.key,
    required this.isCollapsed,
    required this.icon,
    required this.text,
    this.onTap,
    this.isSelected = false,
  });

  @override
  State<SideBarButton> createState() => _SideBarButtonState();
}

class _SideBarButtonState extends State<SideBarButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color iconColor = widget.isSelected
        ? theme.colorScheme.primary
        : (_isHovered
            ? theme.colorScheme.primary.withOpacity(0.9)
            : theme.iconTheme.color?.withOpacity(0.7) ?? Colors.grey[600]!);
    final Color textColor = widget.isSelected
        ? theme.colorScheme.primary
        : (_isHovered
            ? theme.colorScheme.primary.withOpacity(0.9)
            : theme.textTheme.bodyLarge?.color ?? Colors.black87);
    final Color backgroundColor = widget.isSelected
        ? theme.colorScheme.primary.withOpacity(0.1)
        : (_isHovered
            ? theme.colorScheme.onSurface.withOpacity(0.05)
            : Colors.transparent);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: widget.onTap,
        onHover: (hovering) {
          setState(() {
            _isHovered = hovering;
          });
        },
        borderRadius: BorderRadius.circular(8),
        splashColor: theme.colorScheme.primary.withOpacity(0.12),
        highlightColor: theme.colorScheme.primary.withOpacity(0.1),
        child: Container(
          width: widget.isCollapsed
              ? 56
              : double
                  .infinity, // Fixed width for collapsed icon, full for expanded
          padding: EdgeInsets.symmetric(
            vertical: widget.isCollapsed ? 12 : 14, // Adjusted padding
            horizontal: widget.isCollapsed
                ? 0
                : 16, // No horizontal padding when collapsed
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: widget.isCollapsed
              ? Center(
                  child: Icon(
                    widget.icon,
                    color: iconColor,
                    size: 22,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      widget.icon,
                      color: iconColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      // Ensure text doesn't overflow
                      child: Text(
                        widget.text,
                        style: GoogleFonts.roboto(
                          // Or your preferred font
                          fontSize: 15,
                          fontWeight: widget.isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
