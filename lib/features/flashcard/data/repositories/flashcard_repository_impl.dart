import '../../domain/entities/flashcard.dart';
import '../../domain/repositories/flashcard_repository.dart';
import '../datasources/flashcard_data_source.dart';
import '../mappers/flashcard_mapper.dart';

final class FlashcardRepositoryImpl implements FlashcardRepository {
  const FlashcardRepositoryImpl(this.dataSource);

  final FlashcardDataSource dataSource;

  @override
  Future<List<Flashcard>> getFlashcards() async {
    final models = await dataSource.getFlashcards();
    return models.map(FlashcardMapper.toEntity).toList(growable: false);
  }
}