import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quote_model.dart';

class QuoteService {
  static const _url = 'https://api.quotable.io/random';

  Future<QuoteModel> fetchQuote() async {
    try {
      final response = await http
          .get(Uri.parse(_url))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return QuoteModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
      return QuoteModel.fallback;
    } catch (_) {
      return QuoteModel.fallback;
    }
  }
}
