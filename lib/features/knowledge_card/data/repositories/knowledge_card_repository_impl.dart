import '../../domain/entities/knowledge_card.dart';
import '../../domain/repositories/knowledge_card_repository.dart';
import '../datasources/knowledge_card_data_source.dart';
import '../mappers/knowledge_card_mapper.dart';

/// 知识卡片仓库的默认实现。
///
/// Repository 是领域层和数据层之间的桥梁：
/// - 对外接收和返回 [KnowledgeCard]；
/// - 对内调用 [KnowledgeCardDataSource]；
/// - 使用 [KnowledgeCardMapper] 完成实体与数据模型的转换。

final class KnowledgeCardRepositoryImpl implements KnowledgeCardRepository {
  const KnowledgeCardRepositoryImpl(this._dataSource);

  /// 实际执行卡片读写的数据源。
  ///
  /// 当前可以传入内存数据源；
  /// 后续可以替换成本地数据库数据源。
  final KnowledgeCardDataSource _dataSource;

  /// 获取指定知识库中的全部卡片。
  ///
  /// DataSource 返回数据模型，
  /// Repository 将它们转换为领域实体后再交给业务层。
  @override
  Future<List<KnowledgeCard>> getCardsByDeckId(String deckId) async {
    final models = await _dataSource.getCardsByDeckId(deckId);

    return models.map(KnowledgeCardMapper.toEntity).toList(growable: false);
  }

  /// 根据唯一 ID 查找知识卡片。
  ///
  /// 如果 DataSource 没有找到卡片，则返回 `null`。
  @override
  Future<KnowledgeCard?> getCardById(String id) async {
    final model = await _dataSource.getCardById(id);

    if (model == null) {
      return null;
    }

    return KnowledgeCardMapper.toEntity(model);
  }

  /// 新增或更新知识卡片。
  ///
  /// 业务层传入的是领域实体，
  /// 保存前需要先转换成数据模型。
  @override
  Future<void> saveCard(KnowledgeCard card) async {
    final model = KnowledgeCardMapper.toModel(card);

    await _dataSource.saveCard(model);
  }

  /// 删除指定 ID 的知识卡片。
  ///
  /// 删除操作只需要卡片 ID，因此不需要使用 Mapper。
  @override
  Future<void> deleteCard(String id) async {
    await _dataSource.deleteCard(id);
  }
}
