import '../features/flashcard/data/datasources/memory_flashcard_data_source.dart';
import '../features/flashcard/data/repositories/flashcard_repository_impl.dart';
import '../features/flashcard/domain/usecases/get_flashcards.dart';
import '../features/flashcard/presentation/controllers/flashcard_controller.dart';


/// 保存应用启动时需要的依赖
final class AppDependencies {
  AppDependencies({
    required this.flashcardController
  });

  final FlashcardController flashcardController;

/// 创建应用当前使用的依赖
  factory AppDependencies.create() {
    final dataSource = MemoryFlashcardDataSource();
    final repository = FlashcardRepositoryImpl(dataSource);
    final getFlashcards = GetFlashcards(repository);
    final controller = FlashcardController(getFlashcards);

    return AppDependencies(flashcardController: controller);
  }
}