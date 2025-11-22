import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';
import '../../../core/env.dart';
import '../domain/entities/chat_message.dart';
import 'kb_repository.dart';

class GeminiService {
  final GenerativeModel _model;
  final _uuid = const Uuid();
  final KbRepository _kb;

  GeminiService()
      : _model = GenerativeModel(
          model: Env.geminiModel,
          apiKey: Env.geminiKey,
        ),
        _kb = KbRepository();

  Future<ChatMessage> send({
    required List<ChatMessage> history,
    required String userInput,
  }) async {
    // 1) retrieve relevant KB docs
    final kb = await _kb.fetchRelevant(userInput, limit: 3);
  
    // 2) compact context
    final kbContext = kb.isEmpty
        ? 'No internal article matched for this question.'
        : kb.map((d) => '### ${d.title}\n${d.content}').join('\n\n');

    // 3) strict system prompt
    final systemPrompt = '''
You are the official Mobile Induction e-Kit assistant for the university.
Answer ONLY using the "Knowledge Base" context below. If the answer is not
in the KB, reply: "I don't have that info yet."
Keep answers helpful but present it in a normal chat, dont use too many asterisks or whatever.
Don't just list everything like in the knowledge base, present it in a friendly and appealing manner to users and only answer the question being asked.

Knowledge Base:
$kbContext
''';

    // 4) build conversation for Gemini
    final content = <Content>[
      Content.text(systemPrompt),
      ...history.map((m) => m.sender == Sender.user
          ? Content.text(m.text)
          : Content.model([TextPart(m.text)])),
      Content.text(userInput),
    ];

    final response = await _model.generateContent(content);
    final reply = response.text ?? "I don't have that info yet.";
    return ChatMessage(
      id: _uuid.v4(),
      sender: Sender.ai,
      text: reply,
      ts: DateTime.now(),
    );
  }
}
