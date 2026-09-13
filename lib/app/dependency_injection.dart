import '../features/flashcard/data/datasources/memory_flashcard_data_source.dart';
import '../features/flashcard/data/repositories/flashcard_repository_impl.dart';
import '../features/flashcard/domain/usecases/get_flashcards.dart';
import '../features/flashcard/presentation/controllers/flashcard_controller.dart';
import '../features/knowledge_card/data/datasources/memory_knowledge_deck_data_source.dart';
import '../features/knowledge_card/data/repositories/knowledge_deck_repository_impl.dart';
import '../features/knowledge_card/domain/usecases/get_knowledge_decks.dart';
import '../features/knowledge_card/domain/usecases/save_knowledge_deck.dart';
import '../features/knowledge_card/presentation/controllers/create_knowledge_deck_controller.dart';
import '../features/knowledge_card/presentation/controllers/knowledge_deck_controller.dart';
import '../features/main_navigation/presentation/controllers/main_navigation_controller.dart';
import '../features/knowledge_card/data/datasources/knowledge_deck_data_source.dart';

/// 集中创建、保存和释放应用依赖。
final class AppDependencies {
  AppDependencies({
    required this.flashcardController,
    required this.mainNavigationController,
    required this.getKnowledgeDecks,
    required this.knowledgeDeckController,
    required this.createKnowledgeDeckController,
  });

  /// 管理翻卡页面状态。
  final FlashcardController flashcardController;

  /// 管理底部导航的选中状态。
  final MainNavigationController mainNavigationController;

  /// 提供获取知识库列表的业务能力。
  final GetKnowledgeDecks getKnowledgeDecks;

  /// 管理新建知识库表单的保存状态
  final CreateKnowledgeDeckController createKnowledgeDeckController;

  /// 管理知识库列表、加载状态和错误状态。
  ///
  /// KnowledgeDeckController 是类型名。
  /// knowledgeDeckController 是字段名。
  final KnowledgeDeckController knowledgeDeckController;

  /// 按照依赖顺序创建对象。
  factory AppDependencies.create({
    KnowledgeDeckDataSource? knowledgeDeckDataSource,
  }) {
    // 1. 翻卡功能：数据源 → 仓库 → 用例 → 控制器。
    final flashcardDataSource = MemoryFlashcardDataSource();

    final flashcardRepository = FlashcardRepositoryImpl(flashcardDataSource);

    final getFlashcards = GetFlashcards(flashcardRepository);

    final flashcardController = FlashcardController(getFlashcards);

    // 2. 导航功能只需要控制器。
    final mainNavigationController = MainNavigationController();

    // 3. 知识库功能：数据源 → 仓库 → 用例 → 控制器。
    /// 未传入持久化数据源时继续使用内存实现，方便测试和渐进性迁移
    final resolvedKnowledgeDeckDataSource =
        knowledgeDeckDataSource ?? MemoryKnowledgeDeckDataSource();
    final knowledgeDeckRepository = KnowledgeDeckRepositoryImpl(
      resolvedKnowledgeDeckDataSource,
    );

    final saveKnowledgeDeck = SaveKnowledgeDeck(knowledgeDeckRepository);
    final createKnowledgeDeckController = CreateKnowledgeDeckController(
      saveKnowledgeDeck,
    );

    final getKnowledgeDecks = GetKnowledgeDecks(knowledgeDeckRepository);

    // 左边是变量名，右边是调用类的构造函数。
    final knowledgeDeckController = KnowledgeDeckController(getKnowledgeDecks);

    // 4. 保存创建好的依赖，供应用使用。
    return AppDependencies(
      flashcardController: flashcardController,
      mainNavigationController: mainNavigationController,
      getKnowledgeDecks: getKnowledgeDecks,
      knowledgeDeckController: knowledgeDeckController,
      createKnowledgeDeckController: createKnowledgeDeckController,
    );
  }

  /// 在整组依赖不再使用时，由应用的持有者调用一次。
  ///
  /// 页面只借用控制器，不应单独释放这些共享对象。
  /// 普通内存数据源和业务用例目前不需要释放。
  void dispose() {
    flashcardController.dispose();
    mainNavigationController.dispose();
    knowledgeDeckController.dispose();
    createKnowledgeDeckController.dispose();
  }
}
