// lib/widgets/search_section.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:searchsimple/pages/chat_page.dart';
import 'package:searchsimple/services/chat_web_service.dart';
// No direct AppColor imports unless it's for the NEW theme definition itself.

class SearchSection extends StatefulWidget {
  final String? title;
  final String? tagline;
  final String? hintText;

  const SearchSection({
    super.key,
    this.title,
    this.tagline,
    this.hintText,
  });

  @override
  State<SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
  final queryController = TextEditingController();

  @override
  void dispose() {
    queryController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    final query = queryController.text.trim();
    if (query.isNotEmpty) {
      try {
        ChatWebService().chat(query);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatPage(initialQuestion: query),
          ),
        );
      } catch (e) {
        print("Error sending chat message from SearchSection: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Error sending message. Please try again.")));
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter a search query.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Use the global theme

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.title ?? 'Simple Search',
          style: theme.textTheme.displaySmall
              ?.copyWith(color: theme.colorScheme.primary), // Use theme
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        if (widget.tagline != null && widget.tagline!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.tagline!,
              style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color
                      ?.withOpacity(0.8)), // Use theme
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 32),
        Container(
          width: MediaQuery.of(context).size.width > 700
              ? 650
              : MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
              color: theme.cardColor, // Use theme
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.08), // Use theme
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                )
              ],
              border: Border.all(
                  color: theme.dividerColor.withOpacity(0.5),
                  width: 0.5) // Use theme
              ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                child: Icon(Icons.search,
                    color: theme.iconTheme.color?.withOpacity(0.7),
                    size: 22), // Use theme
              ),
              Expanded(
                child: TextField(
                  controller: queryController,
                  style: theme.textTheme.bodyMedium, // Use theme
                  decoration: InputDecoration(
                    hintText: widget.hintText ?? 'Ask anything...',
                    hintStyle:
                        theme.inputDecorationTheme.hintStyle, // Use theme
                    border: InputBorder
                        .none, // Override default input decoration border from theme if needed here
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onSubmitted: (_) => _submitSearch(),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: theme.colorScheme.primary, // Use theme
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: _submitSearch,
                  borderRadius: BorderRadius.circular(20),
                  splashColor: theme.colorScheme.onPrimary.withOpacity(0.2),
                  highlightColor: theme.colorScheme.onPrimary.withOpacity(0.1),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: theme.colorScheme.onPrimary, // Use theme
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ],
    );
  }
}
