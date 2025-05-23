// lib/widgets/side_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:perplexity_clone/theme/colors.dart'; // We'll use Theme.of(context)
import 'package:searchsimple/widgets/side_bar_button.dart';

// Define a model for navigation items if it gets complex
class NavItem {
  final IconData icon;
  final String title;
  final String routeName; // Or a VoidCallback onTap;

  NavItem({required this.icon, required this.title, required this.routeName});
}

class SideBar extends StatefulWidget {
  // Callback to inform HomePage about collapse state if needed for main content padding
  final Function(bool)? onCollapsedStateChanged;
  final String currentRoute; // To highlight the selected button

  const SideBar(
      {super.key, this.onCollapsedStateChanged, this.currentRoute = '/'});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  bool isCollapsed = true; // Default to collapsed, or load from preference

  final List<NavItem> navItems = [
    NavItem(
        icon: Icons.search_outlined,
        title: "New Search",
        routeName: "/"), // Home/New Search
    NavItem(
        icon: Icons.history_outlined, title: "History", routeName: "/history"),
    NavItem(
        icon: Icons.settings_outlined,
        title: "Settings",
        routeName: "/settings"),
    NavItem(icon: Icons.info_outline, title: "About", routeName: "/about"),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isCollapsed ? 72 : 230, // Standard collapsed and expanded widths
      color: isDark
          ? theme.colorScheme.surface.withOpacity(0.5)
          : theme.canvasColor, // Use theme colors
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: isCollapsed ? 0 : 16.0, bottom: 20),
            child: isCollapsed
                ? Center(
                    child: Icon(
                      Icons.search_rounded, // A generic "Simple Search" icon
                      color: theme.colorScheme.primary,
                      size: 30,
                    ),
                  )
                : Text(
                    "Simple Search",
                    style: GoogleFonts.montserrat(
                        // Or your app's brand font
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary),
                  ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                return SideBarButton(
                  isCollapsed: isCollapsed,
                  icon: item.icon,
                  text: item.title,
                  isSelected: widget.currentRoute == item.routeName,
                  onTap: () {
                    // Handle navigation:
                    // Navigator.pushNamed(context, item.routeName);
                    // Or use a callback if HomePage manages routing
                    print("Navigate to ${item.routeName}");
                    if (item.routeName == "/") {
                      // Example for "New Search"
                      // Potentially clear chat page or navigate to home
                    }
                  },
                );
              },
            ),
          ),
          const Spacer(), // Pushes the toggle button to the bottom
          Divider(
            height: 1,
            thickness: 0.5,
            color: theme.dividerColor.withOpacity(0.5),
            indent: isCollapsed ? 8 : 16,
            endIndent: isCollapsed ? 8 : 16,
          ),
          SideBarButton(
            isCollapsed: isCollapsed,
            icon: isCollapsed
                ? Icons.keyboard_arrow_right_rounded
                : Icons.keyboard_arrow_left_rounded,
            text: isCollapsed ? "" : "Collapse", // Text only when expanded
            onTap: () {
              setState(() {
                isCollapsed = !isCollapsed;
                if (widget.onCollapsedStateChanged != null) {
                  widget.onCollapsedStateChanged!(isCollapsed);
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
