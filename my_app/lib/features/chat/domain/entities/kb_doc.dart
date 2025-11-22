class KbDoc { //This is my knowledge base
  final String id; //final is used as we cannot change it later
  final String title;
  final String content;
  final List<String> keywords;

  KbDoc({
    required this.id,
    required this.title,
    required this.content,
    required this.keywords,
  });

  factory KbDoc.fromMap(String id, Map<String, dynamic> m) => KbDoc( //factory constructor used because it needs to create a KbDoc object from a Map, which requires running extra logic
        id: id,
        title: (m['title'] ?? '') as String, //the title is set to the value of title from the map m, we passed m as parameter above
        content: (m['content'] ?? '') as String,
        keywords: (m['keywords'] as List?)?.map((e) => e.toString()).toList() ?? const [],            
      );
}

//the map is a collection of key-value pair. e.g key=title, value=University Library
//Map<String, dynamic> String means every Key must be a string. 
//                     Dynamic means the value can be anything(String, number, list...) 
// ?? [] means return empty list if m['keywords'] as List<String>?) is empty
// title: (m['title'] ?? '') as String, the ?? means if the title is blank, use empty string ''. to avoid null
//keywords: (m['keywords'] as List<String>?) ?? [],