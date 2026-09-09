import 'card_type.dart';

/// 保存一个可复习知识点的通用卡片
/// 该实体只保存所有卡片类型共享的信息。选择题选项，录音设置和
/// 跟读设置等专有内容，将由不同类型的配置对象负责
class KnowledgeCard {
  const KnowledgeCard({
    required this.id,
    required this.deckId,
    required this.type,
    required this.prompt,
    required this.answer,
    required this.createdAt,
    required this.updatedAt,
    this.explanation,
    this.tags = const [],
    this.source,
    this.nextReviewAt,
  });

  final String id;
  // 所属知识库ID
  final String deckId;
  // 卡片的练习和作答类型
  final CardType type;

  // 用户作答前看到的问题，单词或者提示
  final String prompt;

  // 参考答案。不同卡片类型可以有额外的判定配置。
  final String answer;

  // 用户提交答案后看到的可选解析
  final String? explanation;
  // 用于搜索和筛选卡片的标签
  final List<String> tags;
  // 知识点来源
  final String? source;
  final DateTime createdAt;
  final DateTime updatedAt;
  // 根据复习计算下一次复习时间
  final DateTime? nextReviewAt;
}
