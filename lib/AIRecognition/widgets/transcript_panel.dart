import 'package:flutter/material.dart';
import 'package:visualguide/AIRecognition/models/transcript_message.dart';

class TranscriptPanel extends StatefulWidget {
  final List<TranscriptMessage> messages;
  final String inProgressText;
  final VoidCallback? onStop;

  const TranscriptPanel({
    Key? key,
    required this.messages,
    this.inProgressText = '',
    this.onStop,
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
      height: 180, // fixed panel height; adjust as needed
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: Offset(0, -2)),
        ],
      ),
      child: Column(
        children: [
          // Header with optional STOP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFF239B56),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'Conversation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (widget.onStop != null)
                  TextButton.icon(
                    onPressed: widget.onStop,
                    icon: const Icon(Icons.stop, color: Colors.white, size: 18),
                    label: const Text(
                      'STOP',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                    ),
                  ),
              ],
            ),
          ),
          // Scrollable list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: totalItems,
              itemBuilder: (context, index) {
                final showingProgress = index == widget.messages.length &&
                    widget.inProgressText.isNotEmpty;

                if (showingProgress) {
                  return _bubble(
                    speaker: 'User',
                    text: widget.inProgressText,
                    isUser: true,
                    isLive: true,
                  );
                }

                final msg = widget.messages[index];
                return _bubble(
                  speaker: msg.speaker,
                  text: msg.text,
                  isUser: msg.speaker.toLowerCase() == 'user',
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble({
    required String speaker,
    required String text,
    required bool isUser,
    bool isLive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFF239B56) : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUser ? Icons.person : Icons.assistant,
              size: 18,
              color: isUser ? Colors.white : Colors.grey[700],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isLive ? const Color(0xFFE8F5E9) : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    speaker,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: isLive ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
