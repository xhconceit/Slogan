import 'package:flutter_test/flutter_test.dart';
import 'package:zaiwan/features/knowledge_card/data/datasources/memory_knowledge_deck_data_source.dart';
import 'package:zaiwan/features/knowledge_card/data/models/knowledge_deck_model.dart';

void main() {
  group("MemoryKnowledgeDeckDataSource", () {
    late MemoryKnowledgeDeckDataSource dataSource;

    /// 每条测试开始前都创新新的数据源
    ///
    /// 这样测试之间不会共享内存数据，避免互相影响
    setUp(() {
      dataSource = MemoryKnowledgeDeckDataSource();
    });

    /// 创建测试使用的知识库模型
    ///
    /// 抽成函数后，各测试只需要传入不同字段
    /// 不必反复编写完整构建代码
    KnowledgeDeckModel createDeck({
      String id = 'deck-1',
      String name = 'Flutter',
      String? description = 'Flutter 学习卡片',
    }) {
      final now = DateTime(2026, 9, 10);

      return KnowledgeDeckModel(
        id: id,
        name: name,
        description: description,
        createdAt: now,
        updatedAt: now,
      );
    }

    test('初始状态没有知识库', () async {
      /// 读取一个未保存过数据的新数据源
      final decks = await dataSource.getDecks();

      /// 新数据源应该返回空列表，而不是 null
      expect(decks, isEmpty);
    });

    test('可以保存并读取知识库', () async {
      final deck = createDeck();
      await dataSource.saveDeck(deck);
      final savedDeck = await dataSource.getDeckById(deck.id);
      // 根据相同 ID 读取时，应得到刚保存的模型
      expect(savedDeck, same(deck));
    });

    test('查询不存在的知识库时返回 null', () async {
      final deck = await dataSource.getDeckById('missing-deck');
      expect(deck, isNull);
    });

    test('可以读取全部知识库', () async {
      final flutterDeck = createDeck(id: 'deck-1', name: 'Flutter');
      final englishDeck = createDeck(id: 'deck-2', name: '英语');

      await dataSource.saveDeck(flutterDeck);
      await dataSource.saveDeck(englishDeck);

      final decks = await dataSource.getDecks();

      expect(decks, hasLength(2));
      expect(decks, containsAll([flutterDeck, englishDeck]));
    });

    test('保存相同 ID 时更新已有知识库', () async {
      final originalDeck = createDeck(id: 'deck-1', name: 'Flutter');
      final updatedDeck = createDeck(id: 'deck-1', name: 'Flutter 进阶');

      await dataSource.saveDeck(originalDeck);
      await dataSource.saveDeck(updatedDeck);

      final decks = await dataSource.getDecks();
      final savedDeck = await dataSource.getDeckById('deck-1');

      /// 相关 ID 应覆盖原数据，不能产生两条记录
      expect(decks, hasLength(1));
      expect(savedDeck?.name, 'Flutter 进阶');
    });

    test('可以删除知识库', () async {
      final deck = createDeck();

      await dataSource.saveDeck(deck);
      await dataSource.deleteDeck(deck.id);

      final deletedDeck = await dataSource.getDeckById(deck.id);

      expect(deletedDeck, isNull);
      expect(await dataSource.getDecks(), isEmpty);
    });

    test('重复删除不存在的知识库不会保错', () async {
      // 删除方法应具有幂等性，多次执行结果保持一致。
      await dataSource.deleteDeck('missing-deck');
      await dataSource.deleteDeck('missing-deck');

      expect(await dataSource.getDecks(), isEmpty);
    });

    test('全部知识库列表不能被调用方修改', () async {
      await dataSource.saveDeck(createDeck());

      final decks = await dataSource.getDecks();

      // getDecks 返回不可修改列表，保护数据源内部状态
      expect(() => decks.add(createDeck(id: 'deck-2')), throwsUnsupportedError);
    });
  });
}
