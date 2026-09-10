import 'card_config.dart';
import 'card_type.dart';

/// 保存一个可复习知识点的通用卡片。
///
/// 卡片只保存所有类型共享的信息，具体答案和作答规则由 [config] 负责。
final class KnowledgeCard {
  KnowledgeCard({
    required this.id,
    required this.deckId,
    required this.prompt,
    required this.config,
    required this.createdAt,
    required this.updatedAt,
    this.explanation,
    List<String> tags = const [],
    this.source,
    this.nextReviewAt,
  }) : tags = List.unmodifiable(tags);

  /// 卡片的唯一标识。
  final String id;

  /// 卡片所属知识库的唯一标识。
  final String deckId;

  /// 用户作答前看到的问题、单词或提示。
  final String prompt;

  /// 当前卡片的专属内容和判定配置。
  final CardConfig config;

  /// 用户提交答案后看到的可选解析。
  final String? explanation;

  /// 用于搜索和筛选卡片的标签。
  final List<String> tags;

  /// 知识点的可选来源。
  final String? source;

  /// 卡片首次创建的时间。
  final DateTime createdAt;

  /// 卡片内容最后一次更新的时间。
  final DateTime updatedAt;

  /// 系统安排的下一次复习时间。
  ///
  /// 为 `null` 表示尚未进入复习计划。
  final DateTime? nextReviewAt;

  /// 卡片类型由专属配置决定，避免类型和配置不一致。
  CardType get type => config.type;
}
