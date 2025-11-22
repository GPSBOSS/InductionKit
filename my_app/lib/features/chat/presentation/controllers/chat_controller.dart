import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_message.dart';
import '../../data/gemini_service.dart';
class ChatState {
  final List<ChatMessage> messages;
  final bool sending;
  final String? error;

  const ChatState({this.messages = const [], this.sending = false, this.error});

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? sending,
    String? error,
  }) => ChatState(
        messages: messages ?? this.messages,
        sending: sending ?? this.sending,
        error: error,
      );
}

final geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService());

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  final service = ref.read(geminiServiceProvider);
  return ChatController(service);
});

class ChatController extends StateNotifier<ChatState> {
  final GeminiService _service;
  final _uuid = const Uuid();

  ChatController(this._service) : super(const ChatState());

  Future<void> send(String userText) async {
    if (userText.trim().isEmpty || state.sending) return;

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      sender: Sender.user,
      text: userText.trim(),
      ts: DateTime.now(),
    );

    final history = [...state.messages, userMsg];
    state = state.copyWith(messages: history, sending: true, error: null);

    try {
      final aiMsg = await _service.send(history: history, userInput: userText);
      state = state.copyWith(messages: [...history, aiMsg], sending: false);
    } catch (e) {
      state = state.copyWith(sending: false, error: e.toString());
    }
  }

  void clear() => state = const ChatState();
}
