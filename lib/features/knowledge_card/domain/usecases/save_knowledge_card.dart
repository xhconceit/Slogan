import '../entities/knowledge_card.dart';
import '../repositories/knowledge_card_repository.dart';

/// 新增或更新知识卡片的业务用例。
///
/// 创建卡片和编辑卡片共用这个用例：
/// - 卡片 ID 不存在时新增；
/// - 卡片 ID 已存在时更新。
final class SaveKnowledgeCard {
  const SaveKnowledgeCard(this._repository);

  /// 提供知识卡片保存能力的 Repository。
  final KnowledgeCardRepository _repository;

  /// 保存一张知识卡片。
  ///
  /// 保存前先检查所有卡片共有的必要字段。
  Future<void> call(KnowledgeCard card) {
    _validate(card);

    return _repository.saveCard(card);
  }

  /// 验证知识卡片的通用字段。
  ///
  /// 不同卡片类型的专属规则由对应的 CardConfig 负责。
  void _validate(KnowledgeCard card) {
    // 卡片 ID 用于查询、更新和删除，因此不能为空。
    if (card.id.trim().isEmpty) {
      throw ArgumentError.value(
        card.id,
        'card.id',
        '卡片 ID 不能为空',
      );
    }

    // 每张卡片必须属于一个知识库。
    if (card.deckId.trim().isEmpty) {
      throw ArgumentError.value(
        card.deckId,
        'card.deckId',
        '知识库 ID 不能为空',
      );
    }

    // 空题面无法形成有效的学习内容。
    if (card.prompt.trim().isEmpty) {
      throw ArgumentError.value(
        card.prompt,
        'card.prompt',
        '卡片题面不能为空',
      );
    }

    // 更新时间不能早于创建时间。
    if (card.updatedAt.isBefore(card.createdAt)) {
      throw ArgumentError.value(
        card.updatedAt,
        'card.updatedAt',
        '更新时间不能早于创建时间',
      );
    }

    // 下次复习时间不能早于创建时间。
    //
    // nextReviewAt 为 null 表示卡片尚未进入复习计划，
    // 因此 null 是合法状态。
    final nextReviewAt = card.nextReviewAt;

    if (nextReviewAt != null &&
        nextReviewAt.isBefore(card.createdAt)) {
      throw ArgumentError.value(
        nextReviewAt,
        'card.nextReviewAt',
        '下次复习时间不能早于创建时间',
      );
    }
  }
}
