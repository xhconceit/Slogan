
import 'package:flutter_test/flutter_test.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/'
    'knowledge_deck.dart';
import 'package:zaiwan/features/knowledge_card/domain/repositories/'
    'knowledge_deck_repository.dart';
import 'package:zaiwan/features/knowledge_card/domain/usecases/'
    'get_knowledge_decks.dart';

/// 用于测试成功场景的知识库 Repository。
///
/// 它不访问真实数据源，只返回测试预先设置的数据。
final class FakeKnowledgeDeckRepository
    implements KnowledgeDeckRepository {
  FakeKnowledgeDeckRepository(this.decks);

  /// 测试预设的知识库列表。
  final List<KnowledgeDeck> decks;

  /// 记录 [getDecks] 被调用的次数。
  int getDecksCallCount = 0;

  @override
  Future<List<KnowledgeDeck>> getDecks() async {
    getDecksCallCount++;

    return decks;
  }

  /// 当前测试只关心获取全部知识库。
  ///
  /// 其他方法不是本次测试的目标，所以暂时抛出未实现错误。
  @override
  Future<KnowledgeDeck?> getDeckById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> saveDeck(KnowledgeDeck deck) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteDeck(String id) {
    throw UnimplementedError();
  }
}

/// 用于测试失败场景的知识库 Repository。
final class FailingKnowledgeDeckRepository
    implements KnowledgeDeckRepository {
  /// 模拟读取知识库时发生错误。
  @override
  Future<List<KnowledgeDeck>> getDecks() {
    return Future.error(StateError('加载知识库失败'));
  }

  @override
  Future<KnowledgeDeck?> getDeckById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> saveDeck(KnowledgeDeck deck) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteDeck(String id) {
    throw UnimplementedError();
  }
}

void main() {
  group('GetKnowledgeDecks', () {
    test('调用 Repository 并返回知识库列表', () async {
      final now = DateTime(2026, 9, 11);
      final expectedDecks = [
        KnowledgeDeck(
          id: 'deck-1',
          name: 'Flutter',
          description: 'Flutter 学习卡片',
          createdAt: now,
          updatedAt: now,
        ),
        KnowledgeDeck(
          id: 'deck-2',
          name: '英语',
          description: '英语学习卡片',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final repository = FakeKnowledgeDeckRepository(
        expectedDecks,
      );
      final getKnowledgeDecks = GetKnowledgeDecks(repository);

      final result = await getKnowledgeDecks();

      // Use Case 应原样返回 Repository 提供的列表。
      expect(result, same(expectedDecks));

      // 一次 Use Case 调用只应读取一次 Repository。
      expect(repository.getDecksCallCount, 1);
    });

    test('没有知识库时返回空列表', () async {
      final repository = FakeKnowledgeDeckRepository([]);
      final getKnowledgeDecks = GetKnowledgeDecks(repository);

      final result = await getKnowledgeDecks();

      expect(result, isEmpty);
      expect(repository.getDecksCallCount, 1);
    });

    test('Repository 加载失败时向上抛出错误', () async {
      final repository = FailingKnowledgeDeckRepository();
      final getKnowledgeDecks = GetKnowledgeDecks(repository);

      // Use Case 当前没有恢复策略，
      // 所以应把 Repository 错误交给上层 Controller 处理。
      await expectLater(
        () => getKnowledgeDecks(),
        throwsA(isA<StateError>()),
      );
    });
  });
}
