class QuoteModel {
  final String content;
  final String author;

  const QuoteModel({required this.content, required this.author});

  factory QuoteModel.fromJson(Map<String, dynamic> json) => QuoteModel(
        content: json['content'] as String,
        author: json['author'] as String,
      );

  static const fallback = QuoteModel(
    content: 'The secret of getting ahead is getting started.',
    author: 'Mark Twain',
  );
}
