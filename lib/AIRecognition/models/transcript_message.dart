class TranscriptMessage {
  final String speaker;
  final String text;
  final DateTime timestamp;

  TranscriptMessage({
    required this.speaker,
    required this.text,
    required this.timestamp,
  });

  factory TranscriptMessage.fromJson(Map<String, dynamic> json) {
    return TranscriptMessage(
      speaker: json['speaker'] ?? '',
      text: json['text'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speaker': speaker,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}