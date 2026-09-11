import '../features/flashcard/data/datasources/memory_flashcard_data_source.dart';
import '../features/flashcard/data/repositories/flashcard_repository_impl.dart';
import '../features/flashcard/domain/usecases/get_flashcards.dart';
import '../features/flashcard/presentation/controllers/flashcard_controller.dart';
import '../features/knowledge_card/data/datasources/memory_knowledge_deck_data_source.dart';
import '../features/knowledge_card/data/repositories/knowledge_deck_repository_impl.dart';
import '../features/knowledge_card/domain/usecases/get_knowledge_decks.dart';
import '../features/main_navigation/presentation/controllers/main_navigation_controller.dart';

/// 集中创建并保存应用需要的依赖。
///
/// 页面可以使用这里已经组装好的对象，
/// 不需要自己创建数据源、仓库和业务用例。
final class AppDependencies {
  /// 允许调用方传入依赖。
  ///
  /// 正常启动时使用 AppDependencies.create() 统一创建；
/// 测试时也可以通过这个构造函数传入准备好的对象。
  AppDependencies({
    required this.flashcardController,
    required this.mainNavigationController,
    required this.getKnowledgeDecks,
    required this.knowledgeDeckController,
  });

  /// 翻卡页面的控制器，负责加载卡片和管理页面状态。
  final FlashcardController flashcardController;

  /// 一级导航控制器，负责记录当前选中的导航项。
  final MainNavigationController mainNavigationController;

  /// 获取全部知识库的业务用例。
  ///
  /// 后续知识库页面的控制器可以调用：
  /// final decks = await dependencies.getKnowledgeDecks();
  final GetKnowledgeDecks getKnowledgeDecks;


  /// 管理知识库列表，加载状态和错误状态
  ///
  /// 后续知识库页面通过这个控制器读取数据
  final knowledgeDeckController knowledgeDeckController;

  /// 按依赖顺序组装应用需要的对象。
  ///
  /// 数据源 → 仓库 → 业务用例 → 控制器（如果已有）。
  factory AppDependencies.create() {
    // ── 1. 翻卡功能 ──

    // 使用内存数据源提供现有翻卡功能的数据。
    final flashcardDataSource = MemoryFlashcardDataSource();

    // 仓库连接数据源与业务层，负责数据模型转换。
    final flashcardRepository = FlashcardRepositoryImpl(
      flashcardDataSource,
    );

    // 业务用例提供“获取卡片列表”的入口。
    final getFlashcards = GetFlashcards(
      flashcardRepository,
    );

    // 控制器调用业务用例，并管理翻卡页面的状态。
    final flashcardController = FlashcardController(
      getFlashcards,
    );

    // ── 2. 一级导航 ──

    // 导航只管理选中状态，暂时不需要仓库和数据源。
    final mainNavigationController = MainNavigationController();

    // ── 3. 知识库功能 ──

    // 创建知识库的内存数据源。
    // 默认没有知识库；数据只保存在内存中，重启应用后不会保留。
    final knowledgeDeckDataSource = MemoryKnowledgeDeckDataSource();

    // 仓库将数据源返回的模型转换为业务层使用的知识库实体。
    final knowledgeDeckRepository = KnowledgeDeckRepositoryImpl(
      knowledgeDeckDataSource,
    );

    // 创建“获取全部知识库”的业务用例。
    // 它使用上面同一个仓库实例读取知识库。
    final getKnowledgeDecks = GetKnowledgeDecks(
      knowledgeDeckRepository,
    );

    // 将业务用例传给控制器
    // 这里只创建对象，加载操作之后由页面触发
    final knowledgeDeckController = knowledgeDeckController(
    getKnowledgeDecks
    );

    // ── 4. 保存组装好的依赖 ──

    // 将对象放入 AppDependencies，
    // 供应用其他部分通过字段访问。
    return AppDependencies(
      flashcardController: flashcardController,
      mainNavigationController: mainNavigationController,
      getKnowledgeDecks: getKnowledgeDecks,
      knowledgeDeckController: knowledgeDeckController
    );
  }
}
