import '../models/knowledge_card_model.dart';
import 'knowledge_card_data_source.dart';

/// 将知识卡片临时保存在内存中的数据源
///
///这个实现主要用于开发和测试
///- 数据保存在 [_cards] 中
/// - 应用退出后数据会消失；
/// - 后续可以替换成本地数据库实现。
final class MemoryKnowledgeCardDataSource implements KnowledgeCardDataSource {
  MemoryKnowledgeCardDataSource({
    List<KnowledgeCardModel> initialCards = const [],
  }) : _cards = {
         // 使用卡片 ID 作为键 方便查询，更新，删除
         for (final card in initialCards) card.id: card,
       };

  /// 内存中的全部知识卡片
  ///
  /// Key 是卡片 ID Value 是对应的卡片数据模型
  final Map<String, KnowledgeCardModel> _cards;

  /// 获取指定知识库中的全部卡片
  @override
  Future<List<KnowledgeCardModel>> getCardsByDeckId(String deckId) async {
    final cards = _cards.values
        // 只保留属于指定知识库的卡片
        .where((card) => card.deckId == deckId)
        .toList(growable: false);

    // 返回不可修改的列表 防止调用方改变数据源内部状态。
    return List.unmodifiable(cards);
  }

  /// 根据唯一 ID 查找卡片。
  ///
  /// Map 可以直接通过键查询；ID 不存在时会返回 `null`。
  @override
  Future<KnowledgeCardModel?> getCardById(String id) async {
    return _cards[id];
  }

  /// 新增或更新知识卡片。
  ///
  /// 使用 ID 作为 Map 的键，所以保存相同 ID 时会自然覆盖旧数据。
  @override
  Future<void> saveCard(KnowledgeCardModel card) async {
    _cards[card.id] = card;
  }

  /// 删除指定 ID 的知识卡片。
  ///
  /// [Map.remove] 在 ID 不存在时不会抛出异常，
  /// 因此重复删除也是安全的。
  @override
  Future<void> deleteCard(String id) async {
    _cards.remove(id);
  }
}
