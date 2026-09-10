import '../../domain/entities/knowledge_deck.dart';
import '../../domain/repositories/knowledge_deck_repository.dart';
import '../datasources/knowledge_deck_data_source.dart';
import '../mappers/knowledge_deck_mapper.dart';

/// 知识库的默认实现
///
/// Repository 负责连接领域层和数据层
/// - 对外暴露 [KnowledgeDeck] 领域实体
/// - 对内调用 [KnowledgeDeckDataSource]
/// - 使用 [KnowledgeDeckMapper] 转换实体和数据模型
final class KnowledgeDeckRepositoryImpl implements KnowledgeDeckRepository {
  const KnowledgeDeckRepositoryImpl(this._dataSource);

  /// 实际保存和读取知识库的数据源
  ///
  /// 当前可以传入内存数据源，后续也可以替换成本地数据库数据源
  final KnowledgeDeckDataSource _dataSource;

  /// 获取全部知识库
  ///
  /// 数据源返回的数据模型
  /// Repository 将每个数据转换为领域实体后再返回
  @override
  Future<List<KnowledgeDeck>> getDecks() async {
    final models = await _dataSource.getDecks();
    return models.map(KnowledgeDeckMapper.toEntity).toList(growable: false);
  }

  /// 根据唯一 ID 查找知识库
  ///
  /// 找不到时数据源返回 null Repository 也直接返回 null
  @override
  Future<KnowledgeDeck?> getDeckById(String id) async {
    final model = await _dataSource.getDeckById(id);
    if (model == null) {
      return null;
    }

    return KnowledgeDeckMapper.toEntity(model);
  }

  /// 新增或更新知识库
  ///
  /// 领域实体不能直接交给数据源
  /// 因起先将它转换为数据模型。
  @override
  Future<void> saveDeck(KnowledgeDeck deck) async {
    final model = KnowledgeDeckMapper.toModel(deck);
    await _dataSource.saveDeck(model);
  }

  /// 删除指定 ID 的知识库。
  ///
  /// 删除操作只需要 ID，不涉及模型转换。
  @override
  Future<void> deleteDeck(String id) async {
    await _dataSource.deleteDeck(id);
  }
}
