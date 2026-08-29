import '../../domain/entities/flashcard.dart';
import '../models/flashcard_model.dart';

abstract final class FlashcardMapper {
  static Flashcard toEntity(FlashcardModel model) {
    return Flashcard(id: model.id, question: model.question, answer: model.answer);
  }
  static FlashcardModel toModel(Flashcard entity) {
    return FlashcardModel(id: entity.id, question: entity.question, answer: entity.answer);
  }
}