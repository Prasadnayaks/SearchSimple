// lib/widgets/sources_section.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:searchsimple/services/chat_web_service.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart'; // For consistent font

class SourcesSection extends StatefulWidget {
  const SourcesSection({super.key});

  @override
  State<SourcesSection> createState() => _SourcesSectionState();
}

class _SourcesSectionState extends State<SourcesSection> {
  bool _isLoading = true;
  List _searchResults = [];
  String? _errorMessage;
  StreamSubscription? _searchSubscription;

  @override
  void initState() {
    super.initState();
    _subscribeToSearchResults();
  }

  void _subscribeToSearchResults() {
    setState(() {
      _isLoading = true;
      _searchResults = [];
      _errorMessage = null;
    });

    _searchSubscription = ChatWebService().searchResultStream.listen(
      (data) {
        if (mounted) {
          setState(() {
            _searchResults = data['data'] ?? [];
            _isLoading = false;
            _errorMessage = null;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = "Error loading sources: ${error.toString()}";
            _searchResults = [];
          });
          print("Error in SourcesSection searchResultStream: $error");
        }
      },
    );
  }

  @override
  void dispose() {
    _searchSubscription?.cancel();
    super.dispose();
  }

  Future<void> _launchSourceUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print('Could not launch $urlString');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open source: $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_errorMessage != null) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(_errorMessage!,
            style: TextStyle(
                color: theme.colorScheme.error,
                fontFamily: GoogleFonts.roboto().fontFamily)),
      ));
    }

    if (!_isLoading && _searchResults.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.source_outlined,
                  color: theme.iconTheme.color?.withOpacity(0.7)),
              const SizedBox(width: 8),
              Text("Sources",
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          Center(
              child:
                  Text("No sources found.", style: theme.textTheme.bodyMedium)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.source_outlined,
              color: theme.iconTheme.color?.withOpacity(0.7),
            ),
            const SizedBox(width: 8),
            Text(
              "Sources",
              style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight:
                      FontWeight.w600), // Consistent with AnswerSection title
            )
          ],
        ),
        const SizedBox(height: 16),
        Skeletonizer(
          enabled: _isLoading,
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _searchResults.map((res) {
              String title = res['title'] ?? 'No title';
              String url = res['url'] ?? '';
              String displayUrl =
                  url.isNotEmpty ? Uri.parse(url).host : 'No URL';

              return Material(
                // Added Material for InkWell effect
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(8),
                elevation:
                    _isLoading ? 0 : 0.5, // Subtle elevation when not loading
                shadowColor: theme.shadowColor.withOpacity(0.1),
                child: InkWell(
                  onTap: () {
                    if (url.isNotEmpty) {
                      _launchSourceUrl(url);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  splashColor: theme.colorScheme.primary.withOpacity(0.1),
                  highlightColor: theme.colorScheme.primary.withOpacity(0.05),
                  child: Container(
                    width: 160,
                    padding: const EdgeInsets.all(12),
                    // Decoration now handled by Material mostly
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize
                          .min, // Important for consistent card height if text varies
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurface),
                          maxLines: 3, // Allow a bit more text for titles
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          displayUrl,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        )
      ],
    );
  }
}
