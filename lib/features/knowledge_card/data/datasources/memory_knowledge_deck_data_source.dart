import '../models/knowledge_deck_model.dart';
import 'knowledge_deck_data_source.dart';

/// 将知识库临时保存在应用内存中的数据源
///
/// 这个实现主要用于开发和测试：
/// - 数据只保存在 [_decks] 中；
/// - 应用退出后数据会消失；
/// - 后续可以替换成本地数据库实现。
final class MemoryKnowledgeDeckDataSource implements KnowledgeDeckDataSource {
  MemoryKnowledgeDeckDataSource({
    List<KnowledgeDeckModel> initialDecks = const [],
  }) : _decks = {
         // 以知识库 ID 作为键，方便通过 ID 查询、更新和删除。
         for (final deck in initialDecks) deck.id: deck,
       };

  // 以内存 Map 保存知识库，键为知识库ID
  final Map<String, KnowledgeDeckModel> _decks;

  /// 获取当前保存的全部知识库。
  ///
  /// 返回不可修改的列表，防止调用方直接修改数据源内部状态。
  @override
  Future<List<KnowledgeDeckModel>> getDecks() async {
    return List.unmodifiable(_decks.values);
  }

  /// 根据唯一 ID 查找知识库。
  ///
  /// 如果不存在对应的知识库，则返回 `null`。
  @override
  Future<KnowledgeDeckModel?> getDeckById(String id) async {
    return _decks[id];
  }

  /// 新增或更新知识库
  ///
  /// 当 Id 不存在时，新增知识库
  /// 当 ID 已经存在，会覆盖旧数据，实现更新操作。
  @override
  Future<void> saveDeck(KnowledgeDeckModel deck) async {
    _decks[deck.id] = deck;
  }

  /// 删除指定 ID 的知识库。
  ///
  /// 如果 ID 不存在，[Map.remove] 不会抛出异常，
  /// 因此重复删除也是安全的。
  @override
  Future<void> deleteDeck(String id) async {
    _decks.remove(id);
  }
}
