import '../entities/flashcard.dart';

abstract interface class FlashcardRepository {
  Future<List<Flashcard>> getFlashcards();
}