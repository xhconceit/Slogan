import 'package:flutter_test/flutter_test.dart';
import 'package:zaiwan/features/knowledge_card/data/datasources/'
    'memory_knowledge_card_data_source.dart';
import 'package:zaiwan/features/knowledge_card/data/models/'
    'knowledge_card_model.dart';

void main() {
  group('MemoryKnowledgeCardDataSource', () {
    late MemoryKnowledgeCardDataSource dataSource;

    setUp(() {
      // 每条测试都使用全新的数据源，避免测试数据互相影响。
      dataSource = MemoryKnowledgeCardDataSource();
    });

    /// 创建测试使用的问答卡数据模型。
    ///
    /// 默认创建属于 deck-1 的 Flutter 问答卡。
    /// 测试可以通过命名参数覆盖需要改变的字段。
    KnowledgeCardModel createCard({
      String id = 'card-1',
      String deckId = 'deck-1',
      String prompt = 'Flutter 使用什么语言？',
      String answer = 'Dart',
    }) {
      final now = DateTime(2026, 9, 11);

      return KnowledgeCardModel(
        id: id,
        deckId: deckId,
        type: 'questionAnswer',
        prompt: prompt,
        typeConfig: {
          'answer': answer,
        },
        createdAt: now,
        updatedAt: now,
      );
    }

    test('初始状态没有卡片', () async {
      final cards = await dataSource.getCardsByDeckId('deck-1');

      expect(cards, isEmpty);
    });

    test('可以保存并根据 ID 读取卡片', () async {
      final card = createCard();

      await dataSource.saveCard(card);
      final savedCard = await dataSource.getCardById(card.id);

      // 内存数据源应该返回刚才保存的模型对象。
      expect(savedCard, same(card));
    });

    test('查询不存在的卡片时返回 null', () async {
      final card = await dataSource.getCardById('missing-card');

      expect(card, isNull);
    });

    test('只返回属于指定知识库的卡片', () async {
      final flutterCard = createCard(
        id: 'card-1',
        deckId: 'flutter-deck',
        prompt: '什么是 Widget？',
      );
      final englishCard = createCard(
        id: 'card-2',
        deckId: 'english-deck',
        prompt: 'apple 是什么意思？',
        answer: '苹果',
      );

      await dataSource.saveCard(flutterCard);
      await dataSource.saveCard(englishCard);

      final flutterCards = await dataSource.getCardsByDeckId(
        'flutter-deck',
      );
      final englishCards = await dataSource.getCardsByDeckId(
        'english-deck',
      );

      // 两个知识库的数据不能混在一起。
      expect(flutterCards, hasLength(1));
      expect(flutterCards.single.id, 'card-1');

      expect(englishCards, hasLength(1));
      expect(englishCards.single.id, 'card-2');
    });

    test('可以读取同一个知识库中的多张卡片', () async {
      final firstCard = createCard(
        id: 'card-1',
        deckId: 'deck-1',
      );
      final secondCard = createCard(
        id: 'card-2',
        deckId: 'deck-1',
        prompt: '什么是 StatefulWidget？',
        answer: '拥有可变状态的 Widget',
      );

      await dataSource.saveCard(firstCard);
      await dataSource.saveCard(secondCard);

      final cards = await dataSource.getCardsByDeckId('deck-1');

      expect(cards, hasLength(2));
      expect(
        cards.map((card) => card.id),
        containsAll(['card-1', 'card-2']),
      );
    });

    test('保存相同 ID 时更新已有卡片', () async {
      final originalCard = createCard(
        id: 'card-1',
        prompt: 'Flutter 使用什么语言？',
      );
      final updatedCard = createCard(
        id: 'card-1',
        prompt: 'Flutter 的主要编程语言是什么？',
      );

      await dataSource.saveCard(originalCard);
      await dataSource.saveCard(updatedCard);

      final cards = await dataSource.getCardsByDeckId('deck-1');
      final savedCard = await dataSource.getCardById('card-1');

      // 相同 ID 应覆盖旧数据，不能生成两张卡片。
      expect(cards, hasLength(1));
      expect(
        savedCard?.prompt,
        'Flutter 的主要编程语言是什么？',
      );
    });

    test('更新卡片所属知识库后不会留在原知识库', () async {
      final originalCard = createCard(
        id: 'card-1',
        deckId: 'deck-1',
      );
      final movedCard = createCard(
        id: 'card-1',
        deckId: 'deck-2',
      );

      await dataSource.saveCard(originalCard);
      await dataSource.saveCard(movedCard);

      final originalDeckCards =
          await dataSource.getCardsByDeckId('deck-1');
      final newDeckCards =
          await dataSource.getCardsByDeckId('deck-2');

      // 更新相同 ID 的卡片后，旧记录已被完整覆盖。
      expect(originalDeckCards, isEmpty);
      expect(newDeckCards, hasLength(1));
      expect(newDeckCards.single.id, 'card-1');
    });

    test('可以删除卡片', () async {
      final card = createCard();

      await dataSource.saveCard(card);
      await dataSource.deleteCard(card.id);

      expect(await dataSource.getCardById(card.id), isNull);
      expect(
        await dataSource.getCardsByDeckId(card.deckId),
        isEmpty,
      );
    });

    test('重复删除不存在的卡片不会报错', () async {
      // 删除操作具有幂等性，重复执行不会改变最终结果。
      await dataSource.deleteCard('missing-card');
      await dataSource.deleteCard('missing-card');

      expect(
        await dataSource.getCardsByDeckId('deck-1'),
        isEmpty,
      );
    });

    test('返回的卡片列表不能被调用方修改', () async {
      await dataSource.saveCard(createCard());

      final cards = await dataSource.getCardsByDeckId('deck-1');

      // 返回不可修改列表，避免调用方误以为修改列表就能修改数据源。
      expect(
        () => cards.add(createCard(id: 'card-2')),
        throwsUnsupportedError,
      );
    });
  });
}
