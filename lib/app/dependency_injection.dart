import '../features/flashcard/data/datasources/memory_flashcard_data_source.dart';
import '../features/flashcard/data/repositories/flashcard_repository_impl.dart';
import '../features/flashcard/domain/usecases/get_flashcards.dart';
import '../features/flashcard/presentation/controllers/flashcard_controller.dart';
import "../features/main_navigation/presentation/controllers/main_navigation_controller.dart";

/// 保存应用启动时需要的依赖
final class AppDependencies {
  AppDependencies({
    required this.flashcardController,
    required this.mainNavigationController
  });

  final FlashcardController flashcardController;
  final MainNavigationController mainNavigationController;

/// 创建应用当前使用的依赖
  factory AppDependencies.create() {
    // Flashcard 功能依赖
    final flashcardDataSource = MemoryFlashcardDataSource();
    final flashcardRepository = FlashcardRepositoryImpl(flashcardDataSource);
    final getFlashcards = GetFlashcards(flashcardRepository);
    final flashcardController = FlashcardController(getFlashcards);

    // 一级导航只有展示状态，暂时没有 data/domain 依赖
    final mainNavigationController = MainNavigationController();

    return AppDependencies(flashcardController: flashcardController,
      mainNavigationController: mainNavigationController
    );
  }
}