import '../entities/knowledge_deck.dart';

/// 提供知识库的读取和写入能力
///
/// 领域层只依赖这个接口，具体数据保存方式由数据层实现

abstract interface class KnowledgeDeckRepository {
  /// 获取全部知识库
  Future<List<KnowledgeDeck>> getDecks();

  /// 根据唯一标识查找知识库
  ///
  /// 找不到对应知识库时返回 null
  Future<KnowledgeDeck?> getDeckById(String id);

  /// 新增或更新知识库
  ///
  /// 不存在相同 ID 时新增，存在相同 ID 时更新。
  Future<void> saveDeck(KnowledgeDeck deck);

  /// 删除指定知识库
  ///
  /// 是否同时删除库中的卡片有上层删除用例统一处理
  Future<void> deleteDeck(String id);
}
