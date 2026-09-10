import '../models/knowledge_card_model.dart';

/// 定义知识卡在数据层的读写能力
///
/// DataSource 只处理 [KnowledgeCardModel] 不接触领域实体
/// 当前可以使用内存实现，后续可以替换成本地数据库实现
abstract interface class KnowledgeCardDataSource {
    /// 获取指定知识库中的全部卡片
    ///
    /// [deckId] 是知识库的唯一卡片
    Future<List<KnowledgeCardModel>> getCardsByDeckId(String deckId);

    /// 根据卡片唯一 ID 查找卡片
    ///
    /// 找不到对于卡片时返回 null
    Future<KnowledgeCardModel?> getCardById(String id);

    /// 新增或更新知识卡片
    ///
    /// ID  不存在时新增
    ///ID 已存在时覆盖原数据
    Future<void> saveCard(KnowledgeCardModel card);

    /// 删除指定 ID 的知识卡片
    ///
    /// ID 不存在时不抛出异常
    Future<void> deleteCard(String id);
  }

