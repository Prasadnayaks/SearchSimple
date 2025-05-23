// lib/pages/home_page.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Assuming your package name in pubspec.yaml is 'simple_search' or similar
// and you've updated import paths if necessary.
// For this example, I'll use 'perplexity_clone' as per your original file structure
// for consistency with your provided file names. Adjust if your package name changed.
import 'package:searchsimple/services/chat_web_service.dart';
import 'package:searchsimple/widgets/search_section.dart'; // Your updated SearchSection
import 'package:searchsimple/widgets/side_bar.dart'; // Your updated SideBar

// Model for Drawer Navigation Items (can be shared or similar to SideBar's NavItem)
class AppDrawerNavItem {
  final IconData icon;
  final String title;
  final String
      routeIdentifier; // To match SideBar's routeName for selection logic
  final VoidCallback onTap;

  AppDrawerNavItem({
    required this.icon,
    required this.title,
    required this.routeIdentifier,
    required this.onTap,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // _currentRouteIdentifier will store the identifier of the selected item
  // This should match the 'routeName' used in your SideBar's NavItem model
  String _currentRouteIdentifier =
      "/"; // Default to the first item (e.g., "New Search")
  bool _isSideBarCollapsed =
      true; // To manage sidebar collapse state for padding adjustments

  @override
  void initState() {
    super.initState();
    // Connect to WebSocket service if not already handled globally
    try {
      // Check if already connected or let ChatWebService handle singleton logic
      ChatWebService().connect();
    } catch (e) {
      print("Error connecting to WebSocket on HomePage init: $e");
      // Optionally, display a non-intrusive error message or retry logic
    }
  }

  // Define navigation items for the Drawer, similar to SideBar
  List<AppDrawerNavItem> _getDrawerNavItems() {
    // These should mirror the items and routeIdentifiers in your SideBar
    return [
      AppDrawerNavItem(
          icon: Icons.search_sharp, // Updated icon
          title: "New Search",
          routeIdentifier: "/",
          onTap: () => _navigateTo("/")),
      AppDrawerNavItem(
          icon: Icons.history_rounded,
          title: "Search History",
          routeIdentifier: "/history",
          onTap: () => _navigateTo("/history")),
      AppDrawerNavItem(
          icon: Icons.settings_outlined,
          title: "Settings",
          routeIdentifier: "/settings",
          onTap: () => _navigateTo("/settings")),
      AppDrawerNavItem(
          icon: Icons.info_outline_rounded,
          title: "About",
          routeIdentifier: "/about",
          onTap: () => _navigateTo("/about")),
    ];
  }

  void _navigateTo(String routeIdentifier) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context); // Close drawer if open
    }
    setState(() {
      _currentRouteIdentifier = routeIdentifier;
    });

    // Placeholder for actual navigation logic
    // You would replace this with your app's navigation (e.g., Navigator.pushNamed)
    print("HomePage: Navigating to ${routeIdentifier}");
    if (routeIdentifier == "/") {
      // Logic for "New Search", e.g., clear previous search results on ChatPage if needed
      // Or simply ensure the SearchSection is ready for a new query.
    } else if (routeIdentifier == "/history") {
      // Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryPage()));
    } // etc.
  }

  Widget _buildMobileNavigationDrawer() {
    final theme = Theme.of(context);
    final navItems = _getDrawerNavItems();

    return Drawer(
      backgroundColor:
          theme.canvasColor, // Use theme's canvas color for drawer background
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: Center(
              child: Text(
                'Simple Search',
                style: GoogleFonts.montserrat(
                  // Use a consistent brand font
                  color: theme.colorScheme.onPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (var item in navItems)
                  ListTile(
                    leading: Icon(item.icon,
                        color: _currentRouteIdentifier == item.routeIdentifier
                            ? theme.colorScheme.primary
                            : theme.iconTheme.color?.withOpacity(0.7)),
                    title: Text(
                      item.title,
                      style: GoogleFonts.roboto(
                        // Consistent app font
                        fontSize: 15,
                        color: _currentRouteIdentifier == item.routeIdentifier
                            ? theme.colorScheme.primary
                            : theme.textTheme.bodyLarge?.color,
                        fontWeight:
                            _currentRouteIdentifier == item.routeIdentifier
                                ? FontWeight.w600
                                : FontWeight.normal,
                      ),
                    ),
                    tileColor: _currentRouteIdentifier == item.routeIdentifier
                        ? theme.colorScheme.primary.withOpacity(0.08)
                        : null,
                    onTap: item.onTap,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Determine if the screen is large enough for a persistent sidebar
    final bool isLargeScreen =
        MediaQuery.of(context).size.width > 800; // Breakpoint

    // Dynamic padding based on sidebar state for large screens
    double mainContentLeftPadding = isLargeScreen ? 30.0 : 0.0;
    // if (isLargeScreen && !_isSideBarCollapsed) {
    //   mainContentLeftPadding = 230 + 30; // Expanded sidebar width + padding
    // } else if (isLargeScreen && _isSideBarCollapsed) {
    //   mainContentLeftPadding = 72 + 30; // Collapsed sidebar width + padding
    // }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: isLargeScreen
          ? null // No AppBar on large screens; SideBar will handle top content or be part of the row
          : AppBar(
              title: Text(
                'Simple Search',
                style: GoogleFonts.montserrat(
                    // Consistent brand font
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimary),
              ),
              backgroundColor: theme.colorScheme.primary,
              iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
              elevation: 1.0, // Subtle elevation
            ),
      drawer: isLargeScreen ? null : _buildMobileNavigationDrawer(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Conditionally display the SideBar
          if (isLargeScreen)
            SideBar(
              currentRoute: _currentRouteIdentifier,
              onCollapsedStateChanged: (isCollapsed) {
                // This callback can be used to adjust HomePage's layout if needed,
                // e.g., the padding of the main content area.
                if (mounted) {
                  setState(() {
                    _isSideBarCollapsed = isCollapsed;
                  });
                }
              },
            ),
          // Main content area
          Expanded(
            child: CustomScrollView(
              // Use CustomScrollView for more complex scrollable layouts
              slivers: <Widget>[
                SliverFillRemaining(
                  // Ensures the content tries to fill remaining space, good for centering
                  hasScrollBody:
                      false, // Important if you want Column to not take infinite height
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        isLargeScreen ? 30.0 : 20.0, // Left padding
                        20.0, // Top padding
                        isLargeScreen ? 30.0 : 20.0, // Right padding
                        20.0 // Bottom padding
                        ),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween, // Pushes footer down
                      children: <Widget>[
                        const Spacer(
                            flex: 2), // Pushes SearchSection towards center
                        const SearchSection(
                            // Pass custom text if your SearchSection supports it:
                            // title: "Simple Search",
                            // tagline: "Ask anything, explore wisely.",
                            // hintText: "Type your query...",
                            ),
                        const Spacer(flex: 3), // Pushes footer down more
                        _buildFooter(theme),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    // Your existing _buildFooter method, ensure it uses theme for styling
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, bottom: 16.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 24.0, // Increased spacing
        runSpacing: 10.0,
        children: [
          _footerLink('About Simple Search', theme),
          _footerLink('Privacy', theme),
          _footerLink('Terms', theme),
        ],
      ),
    );
  }

  Widget _footerLink(String text, ThemeData theme) {
    // Your existing _footerLink method, ensure it uses theme
    return TextButton(
      onPressed: () {
        // Handle footer link tap
        print("$text tapped");
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        foregroundColor: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
      ),
      child: Text(
        text,
        style: GoogleFonts.roboto(
          // Consistent app font
          fontSize: 12,
        ),
      ),
    );
  }
}
