import '../models/flashcard_model.dart';

abstract interface class FlashcardDataSource {
  Future<List<FlashcardModel>> getFlashcards();
}