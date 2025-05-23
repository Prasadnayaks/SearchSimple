// lib/pages/chat_page.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:searchsimple/services/chat_web_service.dart';
import 'package:searchsimple/theme/colors.dart'; // Or use Theme.of(context)
import 'package:searchsimple/widgets/answer_section.dart';
import 'package:searchsimple/widgets/side_bar.dart'; // Your updated SideBar
import 'package:searchsimple/widgets/sources_section.dart';

class ChatPage extends StatefulWidget {
  final String initialQuestion;
  const ChatPage({
    super.key,
    required this.initialQuestion,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late String _currentQuestion;
  final TextEditingController _followUpController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // To pass to SideBar or Drawer for highlighting
  // This page itself isn't a "route" in the nav usually, but you might want a general identifier
  final String _pageRouteIdentifier = "/chat"; // Example identifier

  @override
  void initState() {
    super.initState();
    _currentQuestion = widget.initialQuestion;
    // The ChatWebService().chat() for the initialQuestion should have been called before navigating here.
    // We are just displaying results and allowing follow-ups.
  }

  void _submitFollowUpQuery() {
    final followUpQuery = _followUpController.text.trim();
    if (followUpQuery.isNotEmpty) {
      // Scroll to top to show the new question prominently
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      setState(() {
        _currentQuestion = followUpQuery;
        // Clear previous sections by re-initializing their state indirectly if they listen to new stream events
        // Or, more explicitly, we'd need a way to signal them to reset.
        // For now, ChatWebService().chat() will trigger new stream events.
      });
      ChatWebService().chat(followUpQuery);
      _followUpController.clear();
    }
  }

  @override
  void dispose() {
    _followUpController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Reusing drawer logic from HomePage - ideally, this would be a shared widget
  Widget _buildMobileNavigationDrawer() {
    final theme = Theme.of(context);
    // Dummy items for now, replace with your actual AppDrawerNavItem and logic from HomePage
    final List<Map<String, dynamic>> navItems = [
      {
        "icon": Icons.search_sharp,
        "title": "New Search",
        "routeIdentifier": "/"
      },
      {
        "icon": Icons.history_rounded,
        "title": "History",
        "routeIdentifier": "/history"
      },
    ];

    return Drawer(
      backgroundColor: theme.canvasColor,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            child: Center(
              child: Text(
                'Simple Search',
                style: GoogleFonts.montserrat(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: navItems
                  .map((item) => ListTile(
                        leading: Icon(item["icon"],
                            color:
                                _pageRouteIdentifier == item["routeIdentifier"]
                                    ? theme.colorScheme.primary
                                    : theme.iconTheme.color?.withOpacity(0.7)),
                        title: Text(
                          item["title"],
                          style: GoogleFonts.roboto(
                            fontSize: 15,
                            color:
                                _pageRouteIdentifier == item["routeIdentifier"]
                                    ? theme.colorScheme.primary
                                    : theme.textTheme.bodyLarge?.color,
                            fontWeight:
                                _pageRouteIdentifier == item["routeIdentifier"]
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          ),
                        ),
                        tileColor:
                            _pageRouteIdentifier == item["routeIdentifier"]
                                ? theme.colorScheme.primary.withOpacity(0.08)
                                : null,
                        onTap: () {
                          Navigator.pop(context);
                          // Handle navigation - this would likely go back to HomePage or other pages
                          if (item["routeIdentifier"] == "/") {
                            Navigator.of(context).popUntil((route) =>
                                route.isFirst); // Go back to HomePage
                          }
                        },
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isLargeScreen = MediaQuery.of(context).size.width > 800;
    final double horizontalPadding =
        isLargeScreen ? 40.0 : 16.0; // More padding for large screens

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: isLargeScreen
          ? null
          : AppBar(
              title: Text(
                "Search Results", // Or "Simple Search"
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimary),
              ),
              backgroundColor: theme.colorScheme.primary,
              iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
              elevation: 1.0,
              leading: (ModalRoute.of(context)?.canPop ?? false) &&
                      !isLargeScreen // Show back button if can pop and not large screen
                  ? BackButton(color: theme.colorScheme.onPrimary)
                  : IconButton(
                      // Hamburger for drawer
                      icon: const Icon(Icons.menu),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
            ),
      drawer: isLargeScreen ? null : _buildMobileNavigationDrawer(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLargeScreen)
            SideBar(
                currentRoute:
                    _pageRouteIdentifier), // Pass a relevant route or selected state
          Expanded(
            child: Column(
              // Main content area takes remaining space
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding, vertical: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          _currentQuestion,
                          style: GoogleFonts.montserrat(
                            // Use brand font for question
                            fontSize: isLargeScreen ? 32 : 24,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.headlineMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const SourcesSection(), // Assumes this widget is responsive or handles its own width
                        const SizedBox(height: 24),
                        const AnswerSection(), // Assumes this widget is responsive
                        const SizedBox(
                            height: 100), // Extra space at the bottom
                      ],
                    ),
                  ),
                ),
                _buildFollowUpInput(theme, isLargeScreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpInput(ThemeData theme, bool isLargeScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal:
              isLargeScreen ? 24.0 : 12.0, // More padding on larger screens
          vertical: 8.0),
      decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, -2),
            )
          ],
          border:
              Border(top: BorderSide(color: theme.dividerColor, width: 0.5))),
      child: SafeArea(
        // Ensures input is not obscured by system UI on mobile
        top: false, // Only apply to bottom
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _followUpController,
                style: GoogleFonts.roboto(
                    fontSize: 15, color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: "Ask a follow-up question...",
                  hintStyle: GoogleFonts.roboto(
                      color: theme.hintColor.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: theme.dividerColor.withOpacity(0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    // Style when not focused
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide:
                        BorderSide(color: theme.dividerColor.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                        color: theme.colorScheme.primary, width: 1.5),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  fillColor: theme
                      .scaffoldBackgroundColor, // Match page background or slightly different
                  filled: true,
                ),
                onSubmitted: (_) => _submitFollowUpQuery(),
                textInputAction: TextInputAction.send,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.send_rounded, color: theme.colorScheme.primary),
              onPressed: _submitFollowUpQuery,
              tooltip: "Send",
              iconSize: 24,
            ),
          ],
        ),
      ),
    );
  }
}
