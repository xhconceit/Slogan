import '../entities/knowledge_deck.dart';
import '../repositories/knowledge_deck_repository.dart';

/// 获取全部知识库的业务用例。
///
/// 表现层通过这个用例读取知识库，
/// 不直接依赖 Repository 的具体实现。
final class GetKnowledgeDecks {
  const GetKnowledgeDecks(this._repository);

  /// 提供知识库读取能力的 Repository。
  ///
  /// 这里依赖领域层接口，而不是数据层的具体实现，
  /// 因此业务代码不需要知道数据来自内存还是本地数据库。
  final KnowledgeDeckRepository _repository;

  /// 执行获取全部知识库的操作。
  ///
  /// Dart 允许对象实现 [call] 方法。
  /// 因此调用方可以像调用函数一样使用这个用例：
  ///
  /// ```dart
  /// final decks = await getKnowledgeDecks();
  /// ```
  Future<List<KnowledgeDeck>> call() {
    return _repository.getDecks();
  }
}
