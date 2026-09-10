import '../entities/knowledge_card.dart';
import '../repositories/knowledge_card_repository.dart';

/// 获取指定知识库中全部卡片的业务用例。
///
/// 表现层只需要提供知识库 ID，
/// 用例负责通过 Repository 获取对应的卡片列表。
final class GetKnowledgeCardsByDeckId {
  const GetKnowledgeCardsByDeckId(this._repository);

  /// 提供知识卡片读取能力的 Repository。
  ///
  /// 这里依赖领域层接口，不依赖内存数据源等具体实现。
  final KnowledgeCardRepository _repository;

  /// 获取属于 [deckId] 知识库的全部卡片。
  ///
  /// 使用方式：
  ///
  /// ```dart
  /// final cards = await getKnowledgeCardsByDeckId('deck-1');
  /// ```
  ///
  /// [deckId] 不能为空，避免向数据层发送无效查询。
  Future<List<KnowledgeCard>> call(String deckId) {
    if (deckId.trim().isEmpty) {
      throw ArgumentError.value(
        deckId,
        'deckId',
        '知识库 ID 不能为空',
      );
    }

    return _repository.getCardsByDeckId(deckId);
  }
}
