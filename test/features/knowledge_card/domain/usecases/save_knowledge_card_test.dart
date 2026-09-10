import 'package:flutter_test/flutter_test.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/'
    'knowledge_card.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/'
    'question_answer_card_config.dart';
import 'package:zaiwan/features/knowledge_card/domain/repositories/'
    'knowledge_card_repository.dart';
import 'package:zaiwan/features/knowledge_card/domain/usecases/'
    'save_knowledge_card.dart';

/// 记录保存操作的测试 Repository。
final class RecordingKnowledgeCardRepository
    implements KnowledgeCardRepository {
  /// Repository 最后收到的卡片。
  KnowledgeCard? savedCard;

  /// 记录保存方法被调用的次数。
  int saveCallCount = 0;

  @override
  Future<void> saveCard(KnowledgeCard card) async {
    saveCallCount++;
    savedCard = card;
  }

  /// 其他方法不属于当前用例的测试范围。
  @override
  Future<List<KnowledgeCard>> getCardsByDeckId(String deckId) {
    throw UnimplementedError();
  }

  @override
  Future<KnowledgeCard?> getCardById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteCard(String id) {
    throw UnimplementedError();
  }
}

/// 模拟卡片保存失败的 Repository。
final class FailingKnowledgeCardRepository
    implements KnowledgeCardRepository {
  @override
  Future<void> saveCard(KnowledgeCard card) {
    return Future.error(StateError('保存知识卡片失败'));
  }

  @override
  Future<List<KnowledgeCard>> getCardsByDeckId(String deckId) {
    throw UnimplementedError();
  }

  @override
  Future<KnowledgeCard?> getCardById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteCard(String id) {
    throw UnimplementedError();
  }
}

void main() {
  group('SaveKnowledgeCard', () {
    /// 创建测试使用的问答卡。
    KnowledgeCard createCard({
      String id = 'card-1',
      String deckId = 'deck-1',
      String prompt = 'Flutter 使用什么语言？',
      DateTime? createdAt,
      DateTime? updatedAt,
      DateTime? nextReviewAt,
    }) {
      final defaultTime = DateTime(2026, 9, 11, 10);

      return KnowledgeCard(
        id: id,
        deckId: deckId,
        prompt: prompt,
        config: const QuestionAnswerCardConfig(
          answer: 'Dart',
        ),
        createdAt: createdAt ?? defaultTime,
        updatedAt: updatedAt ?? defaultTime,
        nextReviewAt: nextReviewAt,
      );
    }

    test('有效卡片会被传给 Repository 保存', () async {
      final repository = RecordingKnowledgeCardRepository();
      final saveKnowledgeCard = SaveKnowledgeCard(repository);
      final card = createCard();

      await saveKnowledgeCard(card);

      // Use Case 应把同一个领域实体交给 Repository。
      expect(repository.savedCard, same(card));
      expect(repository.saveCallCount, 1);
    });

    test('卡片 ID 为空时抛出参数错误', () {
      final repository = RecordingKnowledgeCardRepository();
      final saveKnowledgeCard = SaveKnowledgeCard(repository);
      final card = createCard(id: '   ');

      expect(
        () => saveKnowledgeCard(card),
        throwsA(isA<ArgumentError>()),
      );

      // 校验失败后不允许访问 Repository。
      expect(repository.saveCallCount, 0);
      expect(repository.savedCard, isNull);
    });

    test('知识库 ID 为空时抛出参数错误', () {
      final repository = RecordingKnowledgeCardRepository();
      final saveKnowledgeCard = SaveKnowledgeCard(repository);
      final card = createCard(deckId: '   ');

      expect(
        () => saveKnowledgeCard(card),
        throwsA(isA<ArgumentError>()),
      );

      expect(repository.saveCallCount, 0);
    });

    test('卡片题面为空时抛出参数错误', () {
      final repository = RecordingKnowledgeCardRepository();
      final saveKnowledgeCard = SaveKnowledgeCard(repository);
      final card = createCard(prompt: '\n  ');

      expect(
        () => saveKnowledgeCard(card),
        throwsA(isA<ArgumentError>()),
      );

      expect(repository.saveCallCount, 0);
    });

    test('更新时间早于创建时间时抛出参数错误', () {
      final repository = RecordingKnowledgeCardRepository();
      final saveKnowledgeCard = SaveKnowledgeCard(repository);
      final card = createCard(
        createdAt: DateTime(2026, 9, 11, 10),
        updatedAt: DateTime(2026, 9, 11, 9),
      );

      expect(
        () => saveKnowledgeCard(card),
        throwsA(isA<ArgumentError>()),
      );

      expect(repository.saveCallCount, 0);
    });

    test('下次复习时间早于创建时间时抛出参数错误', () {
      final repository = RecordingKnowledgeCardRepository();
      final saveKnowledgeCard = SaveKnowledgeCard(repository);
      final card = createCard(
        createdAt: DateTime(2026, 9, 11, 10),
        updatedAt: DateTime(2026, 9, 11, 10),
        nextReviewAt: DateTime(2026, 9, 11, 9),
      );

      expect(
        () => saveKnowledgeCard(card),
        throwsA(isA<ArgumentError>()),
      );

      expect(repository.saveCallCount, 0);
    });

    test('没有下次复习时间时允许保存', () async {
      final repository = RecordingKnowledgeCardRepository();
      final saveKnowledgeCard = SaveKnowledgeCard(repository);
      final card = createCard(nextReviewAt: null);

      await saveKnowledgeCard(card);

      expect(repository.savedCard, same(card));
      expect(repository.saveCallCount, 1);
    });

    test('下次复习时间等于创建时间时允许保存', () async {
      final repository = RecordingKnowledgeCardRepository();
      final saveKnowledgeCard = SaveKnowledgeCard(repository);
      final time = DateTime(2026, 9, 11, 10);
      final card = createCard(
        createdAt: time,
        updatedAt: time,
        nextReviewAt: time,
      );

      await saveKnowledgeCard(card);

      expect(repository.savedCard, same(card));
      expect(repository.saveCallCount, 1);
    });

    test('Repository 保存失败时向上抛出错误', () async {
      final repository = FailingKnowledgeCardRepository();
      final saveKnowledgeCard = SaveKnowledgeCard(repository);
      final card = createCard();

      // 存储失败必须暴露给上层，不能表现为保存成功。
      await expectLater(
        () => saveKnowledgeCard(card),
        throwsA(isA<StateError>()),
      );
    });
  });
}
