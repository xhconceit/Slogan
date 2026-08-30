import '../models/flashcard_model.dart';
import 'flashcard_data_source.dart';

final class MemoryFlashcardDataSource implements FlashcardDataSource {
  @override
  Future<List<FlashcardModel>> getFlashcards() async {
    return [
      FlashcardModel(
        id: 'card-001',
        question: 'What is the capital of France?',
        answer: 'Paris',
      ),
      FlashcardModel(id: 'card-002', question: 'What is 2 + 2?', answer: '4'),
    ];
  }
}
