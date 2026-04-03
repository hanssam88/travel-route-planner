enum MessageRole { user, assistant }

class ChatMessage {
  final MessageRole role;
  final String content;

  const ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
        'role': role == MessageRole.user ? 'user' : 'assistant',
        'content': content,
      };
}
