import 'package:flutter/material.dart';
import 'package:visualguide/AIRecognition/models/transcript_message.dart';

class TranscriptPanel extends StatefulWidget {
  final List<TranscriptMessage> messages;
  final String inProgressText; // <- add this

  const TranscriptPanel({
    Key? key,
    required this.messages,
    this.inProgressText = '',
  }) : super(key: key);

  @override
  State<TranscriptPanel> createState() => _TranscriptPanelState();
}

class _TranscriptPanelState extends State<TranscriptPanel> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant TranscriptPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final lenChanged = widget.messages.length != oldWidget.messages.length;
    final progressChanged = widget.inProgressText != oldWidget.inProgressText;
    if (lenChanged || progressChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalItems =
        widget.messages.length + (widget.inProgressText.isNotEmpty ? 1 : 0);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header (keep your original UI here)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF239B56),
            ),
            child: const Row(
              children: [
                Icon(Icons.chat_bubble_outline, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Conversation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: totalItems,
              itemBuilder: (context, index) {
                final showingProgressSlot = index == widget.messages.length &&
                    widget.inProgressText.isNotEmpty;

                if (showingProgressSlot) {
                  // Live transcription bubble
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFF239B56),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person,
                              size: 20, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.inProgressText,
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final message = widget.messages[index];
                final isUser = message.speaker == 'User';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isUser
                              ? const Color(0xFF239B56)
                              : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isUser ? Icons.person : Icons.assistant,
                          size: 20,
                          color: isUser ? Colors.white : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.speaker,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message.text,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
