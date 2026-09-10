/// 知识卡片在数据层中的可序列化模型。
///
/// 该模型只负责保存和恢复 JSON，不执行答题判定等业务逻辑。
/// 不同卡片类型的专属字段统一保存在 [typeConfig] 中。
final class KnowledgeCardModel {
  KnowledgeCardModel({
    required this.id,
    required this.deckId,
    required this.type,
    required this.prompt,
    required Map<String, dynamic> typeConfig,
    required this.createdAt,
    required this.updatedAt,
    this.schemaVersion = 1,
    this.explanation,
    List<String> tags = const [],
    this.source,
    this.nextReviewAt,
  }) : typeConfig = Map.unmodifiable(typeConfig),
       tags = List.unmodifiable(tags);

  /// 当前 JSON 数据结构的版本。
  ///
  /// 将来字段结构发生变化时，可以根据版本迁移旧数据。
  final int schemaVersion;

  /// 卡片的唯一标识。
  final String id;

  /// 卡片所属知识库的唯一标识。
  final String deckId;

  /// 卡片类型的字符串名称。
  final String type;

  /// 用户作答前看到的问题、单词或提示。
  final String prompt;

  /// 当前卡片类型的专属配置。
  final Map<String, dynamic> typeConfig;

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
  final DateTime? nextReviewAt;

  /// 从 JSON 数据恢复知识卡片模型。
  factory KnowledgeCardModel.fromJson(Map<String, dynamic> json) {
    return KnowledgeCardModel(
      schemaVersion: json['schemaVersion'] as int? ?? 1,
      id: json['id'] as String,
      deckId: json['deckId'] as String,
      type: json['type'] as String,
      prompt: json['prompt'] as String,
      typeConfig: Map<String, dynamic>.from(
        json['typeConfig'] as Map<String, dynamic>,
      ),
      explanation: json['explanation'] as String?,
      tags: List<String>.from(json['tags'] as List<dynamic>? ?? const []),
      source: json['source'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      nextReviewAt: json['nextReviewAt'] == null
          ? null
          : DateTime.parse(json['nextReviewAt'] as String),
    );
  }

  /// 将知识卡片模型转换为可以持久化的 JSON 数据。
  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'id': id,
      'deckId': deckId,
      'type': type,
      'prompt': prompt,
      'typeConfig': typeConfig,
      'explanation': explanation,
      'tags': tags,
      'source': source,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'nextReviewAt': nextReviewAt?.toIso8601String(),
    };
  }
}
