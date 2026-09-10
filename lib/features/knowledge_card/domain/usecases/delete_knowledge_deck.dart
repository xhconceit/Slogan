import '../repositories/knowledge_card_repository.dart';
import '../repositories/knowledge_deck_repository.dart';

/// 删除知识库及其全部卡片的业务用例。
///
/// 删除知识库时必须同时删除属于它的知识卡片，
/// 避免产生找不到所属知识库的孤立卡片。
final class DeleteKnowledgeDeck {
  const DeleteKnowledgeDeck({
    required KnowledgeDeckRepository deckRepository,
    required KnowledgeCardRepository cardRepository,
  }) : _deckRepository = deckRepository,
       _cardRepository = cardRepository;

  /// 提供知识库删除能力的 Repository。
  final KnowledgeDeckRepository _deckRepository;

  /// 提供知识卡片查询和删除能力的 Repository。
  final KnowledgeCardRepository _cardRepository;

  /// 删除指定知识库及其全部卡片。
  ///
  /// [deckId] 不能为空。
  Future<void> call(String deckId) {
    if (deckId.trim().isEmpty) {
      throw ArgumentError.value(
        deckId,
        'deckId',
        '知识库 ID 不能为空',
      );
    }

    return _deleteDeckAndCards(deckId);
  }

  /// 执行级联删除。
  ///
  /// 先删除卡片，全部成功后再删除知识库。
  /// 如果某张卡片删除失败，则保留知识库，
  /// 避免知识库已消失但卡片仍然存在。
  Future<void> _deleteDeckAndCards(String deckId) async {
    final cards = await _cardRepository.getCardsByDeckId(deckId);

    for (final card in cards) {
      await _cardRepository.deleteCard(card.id);
    }

    await _deckRepository.deleteDeck(deckId);
  }
}
