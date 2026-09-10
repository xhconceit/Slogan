import '../models/knowledge_deck_model.dart';
import 'knowledge_deck_data_source.dart';

/// 将知识库临时保存在应用内存中的数据源
///
/// 改实现用于开发和测试。应用退出后，内存中的数据会消失
/// 后续可以在不改变领域层的情况下替换成本地数据库
final class MemoryKnowledgeDeckDataSource implements KnowledgeDeckDataSource {
  MemoryKnowledgeDeckDataSource({
    List<KnowledgeDeckModel> initialDecks = const [],
  }) : _decks = {for (final deck in initialDecks) deck.id: deck};

  // 以内存 Map 保存知识库，键为知识库ID
  final Map<String, KnowledgeDeckModel> _decks;

  /// 返回当前保存的全部知识库
  ///
  /// 返回不可

}
