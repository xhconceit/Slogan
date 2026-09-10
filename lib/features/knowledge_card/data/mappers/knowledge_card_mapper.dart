import '../../domain/entities/card_config.dart';
import '../../domain/entities/card_type.dart';
import '../../domain/entities/choice_card_config.dart';
import '../../domain/entities/choice_option.dart';
import '../../domain/entities/knowledge_card.dart';
import '../../domain/entities/question_answer_card_config.dart';
import '../models/knowledge_card_model.dart';

/// 在知识卡片领域实体和数据模型之间进行转换
///
/// JSON 结构只存在于数据层，领域实体不需要知道数据如何保存；
abstract final class KnowledgeCardMapper {
  /// 将领域实体转换为可保存的数据模型
  static KnowledgeCardModel toModel(KnowledgeCard entity) {
    return KnowledgeCardModel(
      id: entity.id,
      deckId: entity.deckId,
      type: entity.type.name,
      prompt: entity.prompt,
      typeConfig: _configToJson(entity.config),
      explanation: entity.explanation,
      tags: entity.tags,
      source: entity.source,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      nextReviewAt: entity.nextReviewAt,
    );
  }

  /// 将数据模型恢复为领域实体
  static KnowledgeCard toEntity(KnowledgeCardModel model) {
    final type = _cardTypeFromName(model.type);

    return KnowledgeCard(
      id: model.id,
      deckId: model.deckId,
      prompt: model.prompt,
      config: _configFromJson(type, model.typeConfig),
      explanation: model.explanation,
      tags: model.tags,
      source: model.source,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      nextReviewAt: model.nextReviewAt,
    );
  }

  /// 将卡片配置转换为对应的 JSON 结构
  static Map<String, dynamic> _configToJson(CardConfig config) {
    if (config is QuestionAnswerCardConfig) {
      return {'answer': config.answer};
    }

    if (config is ChoiceCardConfig) {
      // Set 本身没有稳定顺序，保存前排序可以让 JSON 输出保持一致。
      final correctOptionIds = config.correctOptionIds.toList()..sort();

      return {
        'options': config.options
            .map((option) => {'id': option.id, 'content': option.content})
            .toList(),
        'correctOptionIds': correctOptionIds,
      };
    }

    throw UnsupportedError('暂不支持保存 ${config.runtimeType}');
  }

  /// 根据卡片类型 JSON 配置恢复成领域配置
  static CardConfig _configFromJson(CardType type, Map<String, dynamic> json) {
    switch (type) {
      case CardType.questionAnswer:
        return QuestionAnswerCardConfig(answer: json['answer'] as String);
      case CardType.singleChoice:
      case CardType.multipleChoice:
        return ChoiceCardConfig(
          type: type,
          options: _optionsFromJson(json['options']),
          correctOptionIds: Set<String>.from(
            json['correctOptionIds'] as List<dynamic>,
          ),
        );
      case CardType.voiceAnswer:
      case CardType.pronunciation:
      case CardType.listening:
        throw UnsupportedError("暂不支持恢复 ${type.name} 类型的卡片");
    }
  }

  /// 将 JSON 选项列表恢复为选择题选项列表
  static List<ChoiceOption> _optionsFromJson(Object? value) {
    final jsonOptions = value as List<dynamic>;
    return jsonOptions.map((value) {
      final json = Map<String, dynamic>.from(value as Map<dynamic, dynamic>);
      return ChoiceOption(
        id: json['id'] as String,
        content: json['content'] as String,
      );
    }).toList();
  }

  /// 将持久化的类型名称转换为领域枚举
  ///
  /// 未知类型抛出 [FormatException], 避免把损坏数据当作有效卡片
  static CardType _cardTypeFromName(String name) {
    for (final type in CardType.values) {
      if (type.name == name) {
        return type;
      }
    }
    throw FormatException("未知的卡片类型: $name");
  }
}
