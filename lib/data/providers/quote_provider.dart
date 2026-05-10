import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/quote_service.dart';
import '../models/quote_model.dart';

final quoteServiceProvider = Provider<QuoteService>((ref) => QuoteService());

final quoteProvider = FutureProvider<QuoteModel>((ref) {
  return ref.watch(quoteServiceProvider).fetchQuote();
});
