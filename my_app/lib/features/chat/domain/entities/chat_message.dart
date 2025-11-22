enum Sender { user, ai }

class ChatMessage {
  final String id;
  final Sender sender;
  final String text;
  final DateTime ts;

  ChatMessage({ //constructor. I have used the Dart-style constructor instead of typical constructors (id = this.id ...)
    required this.id,
    required this.sender,
    required this.text,
    required this.ts,
  });
}
