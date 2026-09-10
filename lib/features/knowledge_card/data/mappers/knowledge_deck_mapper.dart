import '../../domain/entities/knowledge_deck.dart';
import '../models/knowledge_deck_model.dart';

/// 知识库领域实体和数据模型之间进行转换
///
/// 领域层不依赖 JSON 所有存储格式转换都集中在数据层
abstract final class KnowledgeDeckMapper {
  /// 将数据模型转换为领域实体
  static KnowledgeDeck toEntity(KnowledgeDeckModel model) {
    return KnowledgeDeck(
      id: model.id,
      name: model.name,
      description: model.description,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  /// 将领域实体转为数据模型
  static KnowledgeDeckModel toModel(KnowledgeDeck entity) {
    return KnowledgeDeckModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
