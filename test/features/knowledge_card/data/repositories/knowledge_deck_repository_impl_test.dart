import 'package:flutter_test/flutter_test.dart';
import 'package:zaiwan/features/knowledge_card/data/datasources/'
    'memory_knowledge_deck_data_source.dart';
import 'package:zaiwan/features/knowledge_card/data/repositories/'
    'knowledge_deck_repository_impl.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/'
    'knowledge_deck.dart';

void main() {
  group('KnowledgeDeckRepositoryImpl', () {
    late MemoryKnowledgeDeckDataSource dataSource;
    late KnowledgeDeckRepositoryImpl repository;

    setUp(() {
      // 每条测试使用独立的数据源，避免测试数据互相影响。
      dataSource = MemoryKnowledgeDeckDataSource();

      // Repository 通过构造函数获得数据源。
      //
      // 这种写法叫依赖注入：Repository 不负责创建数据源，
      // 因此以后可以方便地换成本地数据库或测试替身。
      repository = KnowledgeDeckRepositoryImpl(dataSource);
    });

    /// 创建测试使用的知识库领域实体。
    KnowledgeDeck createDeck({
      String id = 'deck-1',
      String name = 'Flutter',
      String? description = 'Flutter 学习卡片',
    }) {
      final now = DateTime(2026, 9, 11);

      return KnowledgeDeck(
        id: id,
        name: name,
        description: description,
        createdAt: now,
        updatedAt: now,
      );
    }

    test('初始状态没有知识库', () async {
      final decks = await repository.getDecks();

      expect(decks, isEmpty);
    });

    test('可以保存并根据 ID 读取知识库', () async {
      final deck = createDeck();

      await repository.saveDeck(deck);
      final savedDeck = await repository.getDeckById(deck.id);

      // Repository 对外返回的应该是领域实体。
      expect(savedDeck, isA<KnowledgeDeck>());

      // Mapper 应完整保留实体的全部字段。
      expect(savedDeck?.id, deck.id);
      expect(savedDeck?.name, deck.name);
      expect(savedDeck?.description, deck.description);
      expect(savedDeck?.createdAt, deck.createdAt);
      expect(savedDeck?.updatedAt, deck.updatedAt);
    });

    test('查询不存在的知识库时返回 null', () async {
      final deck = await repository.getDeckById('missing-deck');

      expect(deck, isNull);
    });

    test('可以读取全部知识库', () async {
      final flutterDeck = createDeck(
        id: 'deck-1',
        name: 'Flutter',
      );
      final englishDeck = createDeck(
        id: 'deck-2',
        name: '英语',
      );

      await repository.saveDeck(flutterDeck);
      await repository.saveDeck(englishDeck);

      final decks = await repository.getDecks();

      expect(decks, hasLength(2));

      // KnowledgeDeck 暂时没有实现值相等，
      // 因此这里通过 ID 判断返回结果。
      expect(
        decks.map((deck) => deck.id),
        containsAll(['deck-1', 'deck-2']),
      );
    });

    test('保存相同 ID 时更新已有知识库', () async {
      final originalDeck = createDeck(
        id: 'deck-1',
        name: 'Flutter',
      );
      final updatedDeck = KnowledgeDeck(
        id: originalDeck.id,
        name: 'Flutter 进阶',
        description: originalDeck.description,
        createdAt: originalDeck.createdAt,
        updatedAt: DateTime(2026, 9, 12),
      );

      await repository.saveDeck(originalDeck);
      await repository.saveDeck(updatedDeck);

      final decks = await repository.getDecks();
      final savedDeck = await repository.getDeckById('deck-1');

      // 相同 ID 的保存操作应该更新原记录，而不是新增记录。
      expect(decks, hasLength(1));
      expect(savedDeck?.name, 'Flutter 进阶');
      expect(savedDeck?.updatedAt, DateTime(2026, 9, 12));
    });

    test('可以删除知识库', () async {
      final deck = createDeck();

      await repository.saveDeck(deck);
      await repository.deleteDeck(deck.id);

      expect(await repository.getDeckById(deck.id), isNull);
      expect(await repository.getDecks(), isEmpty);
    });

    test('删除不存在的知识库不会报错', () async {
      // Repository 保留 DataSource 的幂等删除行为。
      await repository.deleteDeck('missing-deck');
      await repository.deleteDeck('missing-deck');

      expect(await repository.getDecks(), isEmpty);
    });
  });
}
