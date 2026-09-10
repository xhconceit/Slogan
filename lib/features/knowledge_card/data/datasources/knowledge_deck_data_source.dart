import '../models/knowledge_deck_model.dart';

/// 定义知识库数据的底层读写能力
///
/// 数据源只处理 [KnowledgeDeckModel] 不接触领域实体
/// 具体实现可以是内存，本地数据库或者；远程服务
abstract interface class KnowledgeDeckDataSource {
    /// 获取数据源中的全部知识库
    Future<List<KnowledgeDeckModel>> getDecks();

    /// 根据唯一标识查找知识库
    ///
    /// 找不到返回 null
    Future<KnowledgeDeckModel?> getDeckById(String id);

    /// 新增或更新知识库
    Future<void> saveDeck(KnowledgeDeckModel deck);

    /// 删除指定知识库
    Future<void> deleteDeck(String id);
  }
