import '../repositories/knowledge_card_repository.dart';

/// 删除单张知识卡片的业务用例。
///
/// 这个用例只负责删除卡片，不删除卡片所属的知识库。
final class DeleteKnowledgeCard {
  const DeleteKnowledgeCard(this._repository);

  /// 提供知识卡片删除能力的 Repository。
  final KnowledgeCardRepository _repository;

  /// 删除指定 ID 的知识卡片。
  ///
  /// [cardId] 不能为空或只包含空白字符。
  Future<void> call(String cardId) {
    if (cardId.trim().isEmpty) {
      throw ArgumentError.value(
        cardId,
        'cardId',
        '卡片 ID 不能为空',
      );
    }

    return _repository.deleteCard(cardId);
  }
}
