import 'package:flutter_test/flutter_test.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/'
    'knowledge_card.dart';
import 'package:zaiwan/features/knowledge_card/domain/repositories/'
    'knowledge_card_repository.dart';
import 'package:zaiwan/features/knowledge_card/domain/usecases/'
    'delete_knowledge_card.dart';

/// 记录卡片删除操作的测试 Repository。
final class RecordingKnowledgeCardRepository
    implements KnowledgeCardRepository {
  /// 记录所有收到的卡片 ID。
  final List<String> deletedCardIds = [];

  @override
  Future<void> deleteCard(String id) async {
    deletedCardIds.add(id);
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
  Future<void> saveCard(KnowledgeCard card) {
    throw UnimplementedError();
  }
}

/// 模拟卡片删除失败的 Repository。
final class FailingKnowledgeCardRepository
    implements KnowledgeCardRepository {
  @override
  Future<void> deleteCard(String id) {
    return Future.error(StateError('删除知识卡片失败'));
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
  Future<void> saveCard(KnowledgeCard card) {
    throw UnimplementedError();
  }
}

void main() {
  group('DeleteKnowledgeCard', () {
    test('将卡片 ID 传给 Repository 删除', () async {
      final repository = RecordingKnowledgeCardRepository();
      final deleteKnowledgeCard = DeleteKnowledgeCard(repository);

      await deleteKnowledgeCard('card-1');

      expect(repository.deletedCardIds, ['card-1']);
    });

    test('卡片 ID 为空字符串时抛出参数错误', () {
      final repository = RecordingKnowledgeCardRepository();
      final deleteKnowledgeCard = DeleteKnowledgeCard(repository);

      expect(
        () => deleteKnowledgeCard(''),
        throwsA(isA<ArgumentError>()),
      );

      // 参数校验失败后不能访问 Repository。
      expect(repository.deletedCardIds, isEmpty);
    });

    test('卡片 ID 只有空白字符时抛出参数错误', () {
      final repository = RecordingKnowledgeCardRepository();
      final deleteKnowledgeCard = DeleteKnowledgeCard(repository);

      expect(
        () => deleteKnowledgeCard('  \n '),
        throwsA(isA<ArgumentError>()),
      );

      expect(repository.deletedCardIds, isEmpty);
    });

    test('可以重复删除相同卡片', () async {
      final repository = RecordingKnowledgeCardRepository();
      final deleteKnowledgeCard = DeleteKnowledgeCard(repository);

      await deleteKnowledgeCard('card-1');
      await deleteKnowledgeCard('card-1');

      // Use Case 不额外检查卡片是否存在，
      // 两次调用都会原样交给幂等的 Repository。
      expect(repository.deletedCardIds, [
        'card-1',
        'card-1',
      ]);
    });

    test('Repository 删除失败时向上抛出错误', () async {
      final repository = FailingKnowledgeCardRepository();
      final deleteKnowledgeCard = DeleteKnowledgeCard(repository);

      // 删除失败不能被静默忽略，应交给 Controller 展示错误。
      await expectLater(
        () => deleteKnowledgeCard('card-1'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
