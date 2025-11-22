import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/entities/kb_doc.dart';

class KbRepository {
  final _db = FirebaseFirestore.instance;

  /// Very simple retrieval: tokenize the question and match against keywords[].
  /// Uses arrayContainsAny (max 10 tokens); then scores client-side.
  Future<List<KbDoc>> fetchRelevant(String question, {int limit = 3}) async {
    final tokens = _tokenize(question);
    if (tokens.isEmpty) return [];

    final queryTokens = tokens.take(10).toList();

    final snap = await _db
        .collection('kb_articles')
        .where('keywords', arrayContainsAny: queryTokens)
        .limit(10)
        .get();

    final docs = snap.docs
        .map((d) => KbDoc.fromMap(d.id, d.data()))
        .toList();

    // int score(List<String> ks) =>
    //     ks.where((k) => tokens.contains(k.toLowerCase())).length;
    int score(List<String> keywords) {
        int count = 0;
        // Loop through each keyword in the document
        for (String k in keywords) {
            // If user's question tokens contain this keyword, increase the count
            if (tokens.contains(k.toLowerCase())) {
            count++;
            }
        }
        // Return how many keywords matched
        return count;
    }

    docs.sort((a, b) => score(b.keywords).compareTo(score(a.keywords)));

    return docs.take(limit).toList(); //return top 3
  }

  List<String> _tokenize(String q) => q
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty)
      .toList();
}
