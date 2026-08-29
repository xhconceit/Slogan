import '../entities/flashcard.dart';
import '../repositories/flashcard_repository.dart';

class GetFlashcards {
  const GetFlashcards(this.repository);

  final FlashcardRepository repository;

  Future<List<Flashcard>> call() {
    return repository.getFlashcards();
  }
}
