import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zaiwan/core/data/database/app_database.dart';
import 'package:zaiwan/features/knowledge_card/data/datasources/sqlite_knowledge_deck_data_source.dart';
import 'package:zaiwan/features/knowledge_card/data/models/knowledge_deck_model.dart';

void main() {
  late Database database;
  late SqliteKnowledgeDeckDataSource dataSource;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    // 使用内存数据库运行测试，但复用生产代码的建表逻辑。
    database = await AppDatabase.open(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );

    dataSource = SqliteKnowledgeDeckDataSource(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('初始状态没有知识库', () async {
    final decks = await dataSource.getDecks();

    expect(decks, isEmpty);
  });

  test('保存后可以按 ID 读取知识库', () async {
    final createdAt = DateTime.utc(2026, 9, 14, 8);
    final updatedAt = DateTime.utc(2026, 9, 14, 9);

    final deck = KnowledgeDeckModel(
      id: 'deck-1',
      name: 'Flutter',
      description: 'Flutter 学习卡片',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    await dataSource.saveDeck(deck);

    final savedDeck = await dataSource.getDeckById('deck-1');

    expect(savedDeck, isNotNull);
    expect(savedDeck!.id, 'deck-1');
    expect(savedDeck.name, 'Flutter');
    expect(savedDeck.description, 'Flutter 学习卡片');
    expect(savedDeck.createdAt, createdAt);
    expect(savedDeck.updatedAt, updatedAt);
  });

  test('查询不存在的知识库时返回 null', () async {
    final deck = await dataSource.getDeckById('missing-deck');

    expect(deck, isNull);
  });

  test('保存相同 ID 时更新已有知识库', () async {
    final createdAt = DateTime.utc(2026, 9, 14, 8);

    final originalDeck = KnowledgeDeckModel(
      id: 'deck-1',
      name: 'Flutter',
      description: null,
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    final updatedDeck = KnowledgeDeckModel(
      id: 'deck-1',
      name: 'Flutter 进阶',
      description: '更新后的描述',
      createdAt: createdAt,
      updatedAt: DateTime.utc(2026, 9, 14, 10),
    );

    await dataSource.saveDeck(originalDeck);
    await dataSource.saveDeck(updatedDeck);

    final decks = await dataSource.getDecks();
    final savedDeck = await dataSource.getDeckById('deck-1');

    expect(decks, hasLength(1));
    expect(savedDeck, isNotNull);
    expect(savedDeck!.name, 'Flutter 进阶');
    expect(savedDeck.description, '更新后的描述');
    expect(savedDeck.createdAt, createdAt);
    expect(savedDeck.updatedAt, updatedDeck.updatedAt);
  });
  test('可以删除知识库，并允许重复删除', () async {
    final now = DateTime.utc(2026, 9, 14, 8);

    final deck = KnowledgeDeckModel(
      id: 'deck-1',
      name: 'Flutter',
      description: null,
      createdAt: now,
      updatedAt: now,
    );

    await dataSource.saveDeck(deck);

    expect(await dataSource.getDeckById('deck-1'), isNotNull);

    await dataSource.deleteDeck('deck-1');

    expect(await dataSource.getDeckById('deck-1'), isNull);
    expect(await dataSource.getDecks(), isEmpty);

    // 再次删除不存在的 ID 不应抛出错误。
    await expectLater(dataSource.deleteDeck('deck-1'), completes);
  });
  test('获取全部知识库时按创建时间倒序排列', () async {
    final olderDeck = KnowledgeDeckModel(
      id: 'older',
      name: '较早创建',
      description: null,
      createdAt: DateTime.utc(2026, 9, 14, 8),
      updatedAt: DateTime.utc(2026, 9, 14, 8),
    );

    final newerDeck = KnowledgeDeckModel(
      id: 'newer',
      name: '较晚创建',
      description: '有描述',
      createdAt: DateTime.utc(2026, 9, 14, 10),
      updatedAt: DateTime.utc(2026, 9, 14, 10),
    );

    // 故意先保存新数据、再保存旧数据，确保结果取决于 SQL 排序。
    await dataSource.saveDeck(newerDeck);
    await dataSource.saveDeck(olderDeck);

    final decks = await dataSource.getDecks();

    expect(decks, hasLength(2));
    expect(decks.map((deck) => deck.id), ['newer', 'older']);
    expect(decks.first.description, '有描述');
    expect(decks.last.description, isNull);
  });
}
