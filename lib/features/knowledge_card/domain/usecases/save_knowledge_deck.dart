import '../entities/knowledge_deck.dart';
import '../repositories/knowledge_deck_repository.dart';

/// 新增或更新知识库的业务用例。
///
/// 创建知识库和编辑知识库都使用这个用例：
/// - ID 不存在时，Repository 新增知识库；
/// - ID 已存在时，Repository 更新知识库。
final class SaveKnowledgeDeck {
  const SaveKnowledgeDeck(this._repository);

  /// 提供知识库保存能力的 Repository。
  final KnowledgeDeckRepository _repository;

  /// 保存一个知识库。
  ///
  /// 保存之前会检查知识库的必要字段，
  /// 防止无效数据进入 Repository 和底层存储。
  Future<void> call(KnowledgeDeck deck) {
    _validate(deck);

    return _repository.saveDeck(deck);
  }

  /// 检查知识库是否满足保存条件。
  void _validate(KnowledgeDeck deck) {
    // ID 用于查询、更新和删除，因此不能为空。
    if (deck.id.trim().isEmpty) {
      throw ArgumentError.value(
        deck.id,
        'deck.id',
        '知识库 ID 不能为空',
      );
    }

    // 空名称无法在页面中正确识别，因此不允许保存。
    if (deck.name.trim().isEmpty) {
      throw ArgumentError.value(
        deck.name,
        'deck.name',
        '知识库名称不能为空',
      );
    }

    // 更新时间不能早于创建时间，否则时间数据自相矛盾。
    if (deck.updatedAt.isBefore(deck.createdAt)) {
      throw ArgumentError.value(
        deck.updatedAt,
        'deck.updatedAt',
        '更新时间不能早于创建时间',
      );
    }
  }
}
