import '../entities/knowledge_card.dart';

/// 提供知识卡片的读取和写入
///
/// Repository 返回领域实体，调用方不需要知道 JSON 或数据库结构。
abstract interface class KnowledgeCardRepository {
  /// 获取指定知识库中的全部卡片
  Future<List<KnowledgeCard>> getCardsByDeckId(String deckId);

  /// 根据唯一标识查找知识卡片
  ///
  /// 找不到对应卡片返回 null
  Future<KnowledgeCard?> getCardById(String id);

  /// 新增或更新知识卡片
  ///
  /// 不存在相同 ID 时新增，存在相同 ID 是更新
  Future<void> saveCard(KnowledgeCard card);

  /// 删除指定知识卡片
  Future<void> deleteCard(String id);
}
