import 'package:flutter_test/flutter_test.dart';
import 'package:zaiwan/features/knowledge_card/data/datasources/memory_knowledge_card_data_source.dart';
import 'package:zaiwan/features/knowledge_card/data/repositories/knowledge_card_repository_impl.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/knowledge_deck.dart';
import 'package:zaiwan/features/knowledge_card/domain/repositories/knowledge_deck_repository.dart';
import 'package:zaiwan/features/knowledge_card/domain/usecases/delete_knowledge_deck.dart';
import 'package:zaiwan/features/knowledge_card/domain/usecases/save_knowledge_deck.dart';
import 'package:zaiwan/features/knowledge_card/presentation/controllers/manage_knowledge_deck_controller.dart';

final class _FakeDeckRepository implements KnowledgeDeckRepository {
  final Map<String, KnowledgeDeck> decks = {};
  Object? saveError;

  @override
  Future<void> deleteDeck(String id) async {
    decks.remove(id);
  }

  @override
  Future<KnowledgeDeck?> getDeckById(String id) async => decks[id];

  @override
  Future<List<KnowledgeDeck>> getDecks() async => decks.values.toList();

  @override
  Future<void> saveDeck(KnowledgeDeck deck) async {
    if (saveError case final error?) throw error;
    decks[deck.id] = deck;
  }
}

void main() {
  late _FakeDeckRepository repository;
  late ManageKnowledgeDeckController controller;
  late KnowledgeDeck deck;

  setUp(() {
    repository = _FakeDeckRepository();
    controller = ManageKnowledgeDeckController(
      saveKnowledgeDeck: SaveKnowledgeDeck(repository),
      deleteKnowledgeDeck: DeleteKnowledgeDeck(
        deckRepository: repository,
        cardRepository: KnowledgeCardRepositoryImpl(
          MemoryKnowledgeCardDataSource(),
        ),
      ),
    );
    deck = KnowledgeDeck(
      id: 'deck-1',
      name: 'Flutter',
      description: '基础',
      createdAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    );
    repository.decks[deck.id] = deck;
    addTearDown(controller.dispose);
  });

  test('编辑时清理输入并保留 ID 和创建时间', () async {
    final success = await controller.updateDeck(
      deck: deck,
      name: '  Flutter 进阶  ',
      description: '  新描述  ',
    );

    final updated = repository.decks[deck.id]!;
    expect(success, isTrue);
    expect(updated.id, deck.id);
    expect(updated.name, 'Flutter 进阶');
    expect(updated.description, '新描述');
    expect(updated.createdAt, deck.createdAt);
    expect(updated.updatedAt.isAfter(deck.updatedAt), isTrue);
    expect(controller.error, isNull);
  });

  test('空描述统一保存为 null', () async {
    await controller.updateDeck(
      deck: deck,
      name: deck.name,
      description: '   ',
    );

    expect(repository.decks[deck.id]!.description, isNull);
  });

  test('删除成功后仓库不再包含知识库', () async {
    final success = await controller.deleteDeck(deck.id);

    expect(success, isTrue);
    expect(repository.decks, isEmpty);
  });

  test('保存失败时返回 false 并保留错误', () async {
    final error = StateError('保存失败');
    repository.saveError = error;

    final success = await controller.updateDeck(deck: deck, name: '新名称');

    expect(success, isFalse);
    expect(controller.error, same(error));
    expect(controller.isBusy, isFalse);
  });
}
