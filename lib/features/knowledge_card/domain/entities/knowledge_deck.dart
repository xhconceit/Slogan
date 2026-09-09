/// 用于组织同一个主题知识卡的知识库
/// 例如 Flutter 英语四级 计算机网络 都可以分别建立知识库
class KnowledgeDeck {
  const KnowledgeDeck({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  // 知识库的唯一ID
  final String id;
  // 展示给用户的知识库名称
  final String name;
  // 对知识库学习范围的可选说明
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
}
