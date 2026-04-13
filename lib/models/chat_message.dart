enum MessageSender { deaf, hearing, system }

class ChatMessage {
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isTranslating;

  ChatMessage({
    required this.text,
    required this.sender,
    DateTime? timestamp,
    this.isTranslating = false,
  }) : timestamp = timestamp ?? DateTime.now();
}
