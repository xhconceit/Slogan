/// 知识库在数据层的可序列化模型
///
/// 负责知识库数据与 JSON 之间的转换，不包含业务判断
final class KnowledgeDeckModel {
  const KnowledgeDeckModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  /// id
  final String id;

  /// 知识库名称
  final String name;

  /// 知识库的可选说明
  final String? description;

  /// 知识库首次创建的时间
  final DateTime createdAt;

  /// 知识库最后一次更新时间
  final DateTime updatedAt;

  /// 从 JSON 数据恢复知识库模型
  factory KnowledgeDeckModel.fromJson(Map<String, dynamic> json) {
    return KnowledgeDeckModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  // 将知识库模型转换成可以
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
