import 'package:flutter_test/flutter_test.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/'
    'knowledge_card.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/'
    'knowledge_deck.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/'
    'question_answer_card_config.dart';
import 'package:zaiwan/features/knowledge_card/domain/repositories/'
    'knowledge_card_repository.dart';
import 'package:zaiwan/features/knowledge_card/domain/repositories/'
    'knowledge_deck_repository.dart';
import 'package:zaiwan/features/knowledge_card/domain/usecases/'
    'delete_knowledge_deck.dart';

/// 记录知识库删除操作的测试 Repository。
final class RecordingDeckRepository
    implements KnowledgeDeckRepository {
  RecordingDeckRepository(this.events);

  /// 保存各个操作的执行顺序。
  final List<String> events;

  int deleteCallCount = 0;
  String? deletedDeckId;

  @override
  Future<void> deleteDeck(String id) async {
    deleteCallCount++;
    deletedDeckId = id;
    events.add('delete-deck:$id');
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
  Future<void> saveDeck(KnowledgeDeck deck) {
    throw UnimplementedError();
  }
}

/// 记录卡片查询和删除操作的测试 Repository。
final class RecordingCardRepository
    implements KnowledgeCardRepository {
  RecordingCardRepository({
    required this.events,
    this.cards = const [],
    this.failingCardId,
    this.failWhenLoading = false,
  });

  final List<String> events;
  final List<KnowledgeCard> cards;

  /// 指定删除哪张卡片时模拟失败。
  final String? failingCardId;

  /// 是否在读取卡片列表时模拟失败。
  final bool failWhenLoading;

  int getCardsCallCount = 0;
  final List<String> deletedCardIds = [];

  @override
  Future<List<KnowledgeCard>> getCardsByDeckId(String deckId) async {
    getCardsCallCount++;
    events.add('get-cards:$deckId');

    if (failWhenLoading) {
      throw StateError('加载卡片失败');
    }

    return cards;
  }

  @override
  Future<void> deleteCard(String id) async {
    events.add('delete-card:$id');

    if (id == failingCardId) {
      throw StateError('删除卡片失败');
    }

    deletedCardIds.add(id);
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
  group('DeleteKnowledgeDeck', () {
    /// 创建指定 ID 的测试问答卡。
    KnowledgeCard createCard(String id) {
      final now = DateTime(2026, 9, 11);

      return KnowledgeCard(
        id: id,
        deckId: 'deck-1',
        prompt: '测试问题',
        config: const QuestionAnswerCardConfig(
          answer: '测试答案',
        ),
        createdAt: now,
        updatedAt: now,
      );
    }

    test('先删除全部卡片，再删除知识库', () async {
      final events = <String>[];
      final deckRepository = RecordingDeckRepository(events);
      final cardRepository = RecordingCardRepository(
        events: events,
        cards: [
          createCard('card-1'),
          createCard('card-2'),
        ],
      );
      final deleteKnowledgeDeck = DeleteKnowledgeDeck(
        deckRepository: deckRepository,
        cardRepository: cardRepository,
      );

      await deleteKnowledgeDeck('deck-1');

      // 操作顺序必须是先查询、再删卡片、最后删知识库。
      expect(events, [
        'get-cards:deck-1',
        'delete-card:card-1',
        'delete-card:card-2',
        'delete-deck:deck-1',
      ]);

      expect(cardRepository.deletedCardIds, [
        'card-1',
        'card-2',
      ]);
      expect(deckRepository.deletedDeckId, 'deck-1');
    });

    test('知识库没有卡片时直接删除知识库', () async {
      final events = <String>[];
      final deckRepository = RecordingDeckRepository(events);
      final cardRepository = RecordingCardRepository(
        events: events,
      );
      final deleteKnowledgeDeck = DeleteKnowledgeDeck(
        deckRepository: deckRepository,
        cardRepository: cardRepository,
      );

      await deleteKnowledgeDeck('deck-1');

      expect(events, [
        'get-cards:deck-1',
        'delete-deck:deck-1',
      ]);
      expect(deckRepository.deleteCallCount, 1);
    });

    test('知识库 ID 为空时不调用任何 Repository', () {
      final events = <String>[];
      final deckRepository = RecordingDeckRepository(events);
      final cardRepository = RecordingCardRepository(
        events: events,
      );
      final deleteKnowledgeDeck = DeleteKnowledgeDeck(
        deckRepository: deckRepository,
        cardRepository: cardRepository,
      );

      expect(
        () => deleteKnowledgeDeck('   '),
        throwsA(isA<ArgumentError>()),
      );

      expect(events, isEmpty);
      expect(cardRepository.getCardsCallCount, 0);
      expect(deckRepository.deleteCallCount, 0);
    });

    test('加载卡片失败时不会删除知识库', () async {
      final events = <String>[];
      final deckRepository = RecordingDeckRepository(events);
      final cardRepository = RecordingCardRepository(
        events: events,
        failWhenLoading: true,
      );
      final deleteKnowledgeDeck = DeleteKnowledgeDeck(
        deckRepository: deckRepository,
        cardRepository: cardRepository,
      );

      await expectLater(
        () => deleteKnowledgeDeck('deck-1'),
        throwsA(isA<StateError>()),
      );

      expect(events, ['get-cards:deck-1']);
      expect(deckRepository.deleteCallCount, 0);
    });

    test('卡片删除失败时不会继续删除知识库', () async {
      final events = <String>[];
      final deckRepository = RecordingDeckRepository(events);
      final cardRepository = RecordingCardRepository(
        events: events,
        cards: [
          createCard('card-1'),
          createCard('card-2'),
          createCard('card-3'),
        ],
        failingCardId: 'card-2',
      );
      final deleteKnowledgeDeck = DeleteKnowledgeDeck(
        deckRepository: deckRepository,
        cardRepository: cardRepository,
      );

      await expectLater(
        () => deleteKnowledgeDeck('deck-1'),
        throwsA(isA<StateError>()),
      );

      expect(events, [
        'get-cards:deck-1',
        'delete-card:card-1',
        'delete-card:card-2',
      ]);

      // 第一张已成功删除，失败后的第三张不会继续删除。
      expect(cardRepository.deletedCardIds, ['card-1']);

      // 卡片没有全部删除成功，因此知识库必须保留。
      expect(deckRepository.deleteCallCount, 0);
    });
  });
}
