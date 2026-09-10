import 'package:flutter_test/flutter_test.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/'
    'knowledge_deck.dart';
import 'package:zaiwan/features/knowledge_card/domain/repositories/'
    'knowledge_deck_repository.dart';
import 'package:zaiwan/features/knowledge_card/domain/usecases/'
    'save_knowledge_deck.dart';

/// 记录保存调用的测试 Repository。
final class RecordingKnowledgeDeckRepository
    implements KnowledgeDeckRepository {
  /// Repository 最后收到的知识库。
  KnowledgeDeck? savedDeck;

  /// 记录保存方法被调用的次数。
  int saveCallCount = 0;

  @override
  Future<void> saveDeck(KnowledgeDeck deck) async {
    saveCallCount++;
    savedDeck = deck;
  }

  /// 其他方法不属于当前用例的测试范围。
  @override
  Future<List<KnowledgeDeck>> getDecks() {
    throw UnimplementedError();
  }

  @override
  Future<KnowledgeDeck?> getDeckById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteDeck(String id) {
    throw UnimplementedError();
  }
}

/// 模拟保存失败的测试 Repository。
final class FailingKnowledgeDeckRepository
    implements KnowledgeDeckRepository {
  @override
  Future<void> saveDeck(KnowledgeDeck deck) {
    return Future.error(StateError('保存知识库失败'));
  }

  @override
  Future<List<KnowledgeDeck>> getDecks() {
    throw UnimplementedError();
  }

  @override
  Future<KnowledgeDeck?> getDeckById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteDeck(String id) {
    throw UnimplementedError();
  }
}

void main() {
  group('SaveKnowledgeDeck', () {
    /// 创建测试使用的有效知识库。
    KnowledgeDeck createDeck({
      String id = 'deck-1',
      String name = 'Flutter',
      DateTime? createdAt,
      DateTime? updatedAt,
    }) {
      final defaultTime = DateTime(2026, 9, 11);

      return KnowledgeDeck(
        id: id,
        name: name,
        description: 'Flutter 学习卡片',
        createdAt: createdAt ?? defaultTime,
        updatedAt: updatedAt ?? defaultTime,
      );
    }

    test('有效知识库会被传给 Repository 保存', () async {
      final repository = RecordingKnowledgeDeckRepository();
      final saveKnowledgeDeck = SaveKnowledgeDeck(repository);
      final deck = createDeck();

      await saveKnowledgeDeck(deck);

      // Use Case 应把同一个领域实体交给 Repository。
      expect(repository.savedDeck, same(deck));
      expect(repository.saveCallCount, 1);
    });

    test('知识库 ID 为空时抛出参数错误', () {
      final repository = RecordingKnowledgeDeckRepository();
      final saveKnowledgeDeck = SaveKnowledgeDeck(repository);
      final deck = createDeck(id: '');

      expect(
        () => saveKnowledgeDeck(deck),
        throwsA(isA<ArgumentError>()),
      );

      // 校验失败后不能把无效数据交给 Repository。
      expect(repository.saveCallCount, 0);
      expect(repository.savedDeck, isNull);
    });

    test('知识库 ID 只有空白字符时抛出参数错误', () {
      final repository = RecordingKnowledgeDeckRepository();
      final saveKnowledgeDeck = SaveKnowledgeDeck(repository);
      final deck = createDeck(id: '   ');

      expect(
        () => saveKnowledgeDeck(deck),
        throwsA(isA<ArgumentError>()),
      );

      expect(repository.saveCallCount, 0);
    });

    test('知识库名称为空时抛出参数错误', () {
      final repository = RecordingKnowledgeDeckRepository();
      final saveKnowledgeDeck = SaveKnowledgeDeck(repository);
      final deck = createDeck(name: '');

      expect(
        () => saveKnowledgeDeck(deck),
        throwsA(isA<ArgumentError>()),
      );

      expect(repository.saveCallCount, 0);
    });

    test('知识库名称只有空白字符时抛出参数错误', () {
      final repository = RecordingKnowledgeDeckRepository();
      final saveKnowledgeDeck = SaveKnowledgeDeck(repository);
      final deck = createDeck(name: '   ');

      expect(
        () => saveKnowledgeDeck(deck),
        throwsA(isA<ArgumentError>()),
      );

      expect(repository.saveCallCount, 0);
    });

    test('更新时间早于创建时间时抛出参数错误', () {
      final repository = RecordingKnowledgeDeckRepository();
      final saveKnowledgeDeck = SaveKnowledgeDeck(repository);
      final deck = createDeck(
        createdAt: DateTime(2026, 9, 11, 10),
        updatedAt: DateTime(2026, 9, 11, 9),
      );

      expect(
        () => saveKnowledgeDeck(deck),
        throwsA(isA<ArgumentError>()),
      );

      expect(repository.saveCallCount, 0);
    });

    test('更新时间等于创建时间时允许保存', () async {
      final repository = RecordingKnowledgeDeckRepository();
      final saveKnowledgeDeck = SaveKnowledgeDeck(repository);
      final time = DateTime(2026, 9, 11, 10);
      final deck = createDeck(
        createdAt: time,
        updatedAt: time,
      );

      await saveKnowledgeDeck(deck);

      expect(repository.savedDeck, same(deck));
      expect(repository.saveCallCount, 1);
    });

    test('Repository 保存失败时向上抛出错误', () async {
      final repository = FailingKnowledgeDeckRepository();
      final saveKnowledgeDeck = SaveKnowledgeDeck(repository);
      final deck = createDeck();

      // Use Case 不应把存储失败伪装成保存成功。
      await expectLater(
        () => saveKnowledgeDeck(deck),
        throwsA(isA<StateError>()),
      );
    });
  });
}
