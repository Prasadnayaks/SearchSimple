// lib/widgets/answer_section.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:searchsimple/services/chat_web_service.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:google_fonts/google_fonts.dart'; // For consistent font

class AnswerSection extends StatefulWidget {
  const AnswerSection({super.key});

  @override
  State<AnswerSection> createState() => _AnswerSectionState();
}

class _AnswerSectionState extends State<AnswerSection> {
  bool _isLoading = true;
  final StringBuffer _fullResponseBuffer = StringBuffer();
  String? _errorMessage;
  StreamSubscription? _contentSubscription;
  bool _streamEnded = false;

  @override
  void initState() {
    super.initState();
    _subscribeToContent();
  }

  void _subscribeToContent() {
    setState(() {
      _isLoading = true;
      _fullResponseBuffer.clear();
      _errorMessage = null;
      _streamEnded = false;
    });

    _contentSubscription = ChatWebService().contentStream.listen(
      (data) {
        if (mounted) {
          setState(() {
            _fullResponseBuffer.write(data['data']);
            if (_isLoading) _isLoading = false;
            _errorMessage = null;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _streamEnded = true;
            _errorMessage = "Error receiving answer: ${error.toString()}";
          });
          print("Error in AnswerSection contentStream: $error");
        }
      },
      onDone: () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _streamEnded = true;
          });
          print("AnswerSection contentStream finished.");
        }
      },
    );
  }

  @override
  void dispose() {
    _contentSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String currentDisplayResponse = _fullResponseBuffer.toString();
    bool shouldSkeletonize =
        _isLoading || (!_streamEnded && currentDisplayResponse.isEmpty);

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

    if (shouldSkeletonize && currentDisplayResponse.isEmpty) {
      return Skeletonizer(
        enabled: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Simple Search is thinking...",
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Container(
                height: 18,
                width: double.infinity,
                color: theme.highlightColor),
            const SizedBox(height: 10),
            Container(
                height: 14,
                width: MediaQuery.of(context).size.width * 0.8,
                color: theme.highlightColor),
            const SizedBox(height: 10),
            Container(
                height: 14,
                width: MediaQuery.of(context).size.width * 0.9,
                color: theme.highlightColor),
            const SizedBox(height: 20),
            Container(
                height: 70,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: theme.highlightColor,
                    borderRadius: BorderRadius.circular(8))),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Simple Search says:",
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        MarkdownBody(
          data: currentDisplayResponse.isEmpty && _streamEnded
              ? "No answer content."
              : currentDisplayResponse,
          selectable: true,
          styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
            codeblockDecoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? theme.colorScheme.surface.withOpacity(0.8)
                    : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.dividerColor)),
            code: GoogleFonts.firaCode(
                // A good monospace font for code
                textStyle: theme.textTheme.bodyMedium?.copyWith(
              backgroundColor:
                  Colors.transparent, // Handled by codeblockDecoration
              fontSize: 13.5, // Typical code font size
            )),
            p: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6, fontSize: 15.5), // Slightly larger body text
            h1: theme.textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w600),
            h2: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w600),
            h3: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
            // Add other styles as needed
            blockquoteDecoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                border: Border(
                    left:
                        BorderSide(color: theme.colorScheme.primary, width: 4)),
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4))),
            blockquotePadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }
}
