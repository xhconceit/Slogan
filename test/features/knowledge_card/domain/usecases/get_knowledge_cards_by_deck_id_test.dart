import 'package:flutter_test/flutter_test.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/'
    'knowledge_card.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/'
    'question_answer_card_config.dart';
import 'package:zaiwan/features/knowledge_card/domain/repositories/'
    'knowledge_card_repository.dart';
import 'package:zaiwan/features/knowledge_card/domain/usecases/'
    'get_knowledge_cards_by_deck_id.dart';

/// 用于测试成功场景的知识卡片 Repository。
final class FakeKnowledgeCardRepository
    implements KnowledgeCardRepository {
  FakeKnowledgeCardRepository(this.cards);

  /// 测试预设的知识卡片列表。
  final List<KnowledgeCard> cards;

  /// 记录 Repository 收到的知识库 ID。
  String? receivedDeckId;

  /// 记录查询方法被调用的次数。
  int getCardsCallCount = 0;

  @override
  Future<List<KnowledgeCard>> getCardsByDeckId(String deckId) async {
    getCardsCallCount++;
    receivedDeckId = deckId;

    return cards;
  }

  /// 其他方法不是本次测试的目标，因此暂不实现。
  @override
  Future<KnowledgeCard?> getCardById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> saveCard(KnowledgeCard card) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteCard(String id) {
    throw UnimplementedError();
  }
}

/// 用于模拟卡片读取失败的 Repository。
final class FailingKnowledgeCardRepository
    implements KnowledgeCardRepository {
  @override
  Future<List<KnowledgeCard>> getCardsByDeckId(String deckId) {
    return Future.error(StateError('加载知识卡片失败'));
  }

  @override
  Future<KnowledgeCard?> getCardById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> saveCard(KnowledgeCard card) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteCard(String id) {
    throw UnimplementedError();
  }
}

void main() {
  group('GetKnowledgeCardsByDeckId', () {
    /// 创建测试使用的问答卡。
    KnowledgeCard createCard() {
      final now = DateTime(2026, 9, 11);

      return KnowledgeCard(
        id: 'card-1',
        deckId: 'deck-1',
        prompt: 'Flutter 使用什么语言？',
        config: const QuestionAnswerCardConfig(
          answer: 'Dart',
        ),
        createdAt: now,
        updatedAt: now,
      );
    }

    test('将知识库 ID 传给 Repository 并返回卡片列表', () async {
      final expectedCards = [createCard()];
      final repository = FakeKnowledgeCardRepository(
        expectedCards,
      );
      final getCards = GetKnowledgeCardsByDeckId(repository);

      final result = await getCards('deck-1');

      // Use Case 应原样返回 Repository 的查询结果。
      expect(result, same(expectedCards));

      // 确保知识库 ID 被正确传递，且只查询一次。
      expect(repository.receivedDeckId, 'deck-1');
      expect(repository.getCardsCallCount, 1);
    });

    test('知识库没有卡片时返回空列表', () async {
      final repository = FakeKnowledgeCardRepository([]);
      final getCards = GetKnowledgeCardsByDeckId(repository);

      final result = await getCards('deck-1');

      expect(result, isEmpty);
      expect(repository.receivedDeckId, 'deck-1');
      expect(repository.getCardsCallCount, 1);
    });

    test('Repository 加载失败时向上抛出错误', () async {
      final repository = FailingKnowledgeCardRepository();
      final getCards = GetKnowledgeCardsByDeckId(repository);

      // Use Case 没有恢复策略，因此保留原始错误。
      await expectLater(
        () => getCards('deck-1'),
        throwsA(isA<StateError>()),
      );
    });

    test('知识库 ID 为空字符串时抛出参数错误', () {
      final repository = FakeKnowledgeCardRepository([]);
      final getCards = GetKnowledgeCardsByDeckId(repository);

      expect(
        () => getCards(''),
        throwsA(isA<ArgumentError>()),
      );

      // 参数校验失败后，不应该继续访问 Repository。
      expect(repository.getCardsCallCount, 0);
    });

    test('知识库 ID 只有空白字符时抛出参数错误', () {
      final repository = FakeKnowledgeCardRepository([]);
      final getCards = GetKnowledgeCardsByDeckId(repository);

      expect(
        () => getCards('   '),
        throwsA(isA<ArgumentError>()),
      );

      expect(repository.getCardsCallCount, 0);
    });
  });
}
