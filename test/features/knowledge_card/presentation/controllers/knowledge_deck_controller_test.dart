import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/knowledge_deck.dart';
import 'package:zaiwan/features/knowledge_card/domain/repositories/knowledge_deck_repository.dart';
import 'package:zaiwan/features/knowledge_card/domain/usecases/get_knowledge_decks.dart';
import 'package:zaiwan/features/knowledge_card/presentation/controllers/knowledge_deck_controller.dart';

/// 测试专用仓库，不访问数据库。
///
/// 每个测试通过 onGetDecks 决定：
/// 返回什么数据、是否失败、什么时候完成。
final class FakeKnowledgeDeckRepository implements KnowledgeDeckRepository {
  Future<List<KnowledgeDeck>> Function() onGetDecks =
      () async => <KnowledgeDeck>[];

  /// 用于检查重复加载是否真的发出了多次请求。
  int getDecksCallCount = 0;

  @override
  Future<List<KnowledgeDeck>> getDecks() {
    getDecksCallCount++;
    return onGetDecks();
  }

  // 控制器只读取列表，其他方法不应被调用。
  // 如果误调用，立即报错，让测试暴露问题。
  @override
  Future<KnowledgeDeck?> getDeckById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> saveDeck(KnowledgeDeck deck) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteDeck(String id) {
    throw UnimplementedError();
  }
}

void main() {
  late FakeKnowledgeDeckRepository repository;
  late KnowledgeDeckController controller;
  late KnowledgeDeck deck;

  setUp(() {
    // 每个测试创建全新对象，避免互相影响。
    repository = FakeKnowledgeDeckRepository();
    controller = KnowledgeDeckController(
      GetKnowledgeDecks(repository),
    );

    final now = DateTime(2026, 9, 11);
    deck = KnowledgeDeck(
      id: 'deck-1',
      name: 'Flutter',
      createdAt: now,
      updatedAt: now,
    );
  });

  group('KnowledgeDeckController', () {
    test('初始状态没有数据、错误或加载任务', () {
      addTearDown(controller.dispose);

      expect(controller.isLoading, isFalse);
      expect(controller.decks, isEmpty);
      expect(controller.error, isNull);
      expect(repository.getDecksCallCount, 0);
    });

    test('加载期间通知页面，成功后保存列表并结束加载', () async {
      addTearDown(controller.dispose);

      // Completer 允许测试手动决定异步请求何时完成，
      // 从而检查“请求尚未完成”时的状态。
      final completer = Completer<List<KnowledgeDeck>>();
      repository.onGetDecks = () => completer.future;

      final loadingStates = <bool>[];
      controller.addListener(() {
        loadingStates.add(controller.isLoading);
      });

      // 暂时不 await，否则会一直等到请求完成。
      final loading = controller.loadDecks();

      expect(controller.isLoading, isTrue);
      expect(controller.error, isNull);
      expect(loadingStates, [true]);

      // 模拟仓库返回数据，再等待控制器处理完毕。
      completer.complete([deck]);
      await loading;

      expect(controller.decks, [deck]);
      expect(controller.isLoading, isFalse);
      expect(controller.error, isNull);
      expect(loadingStates, [true, false]);

      // 页面不能直接修改控制器提供的列表。
      expect(
        () => controller.decks.clear(),
        throwsUnsupportedError,
      );
    });

    test('没有知识库时正常返回空列表', () async {
      addTearDown(controller.dispose);

      await controller.loadDecks();

      expect(controller.decks, isEmpty);
      expect(controller.error, isNull);
      expect(controller.isLoading, isFalse);
    });

    test('刷新失败保留旧数据，重试时清除错误', () async {
      addTearDown(controller.dispose);

      // 第一次加载成功，页面已有内容。
      repository.onGetDecks = () async => [deck];
      await controller.loadDecks();

      // 第二次模拟刷新失败。
      final failure = StateError('读取失败');
      repository.onGetDecks = () async => throw failure;

      await controller.loadDecks();

      expect(controller.error, same(failure));
      expect(controller.isLoading, isFalse);
      expect(controller.decks, [deck]);

      // 第三次重试：请求开始时就应该清除旧错误。
      final retryCompleter = Completer<List<KnowledgeDeck>>();
      repository.onGetDecks = () => retryCompleter.future;

      final retry = controller.loadDecks();

      expect(controller.error, isNull);
      expect(controller.isLoading, isTrue);

      // 成功返回空列表，应该替换之前的旧数据。
      retryCompleter.complete([]);
      await retry;

      expect(controller.decks, isEmpty);
      expect(controller.error, isNull);
      expect(controller.isLoading, isFalse);
    });

    test('加载期间忽略重复请求', () async {
      addTearDown(controller.dispose);

      final completer = Completer<List<KnowledgeDeck>>();
      repository.onGetDecks = () => completer.future;

      final firstLoading = controller.loadDecks();

      // 第一次还没完成，再调用一次。
      await controller.loadDecks();

      // 第二次调用应该被忽略，没有再次读取仓库。
      expect(repository.getDecksCallCount, 1);
      expect(controller.isLoading, isTrue);

      completer.complete([deck]);
      await firstLoading;

      expect(controller.decks, [deck]);
      expect(controller.isLoading, isFalse);
    });

    test('加载期间释放控制器，完成后不再通知页面', () async {
      // 本测试会手动 dispose，所以不再注册 addTearDown。
      final completer = Completer<List<KnowledgeDeck>>();
      repository.onGetDecks = () => completer.future;

      var notificationCount = 0;
      controller.addListener(() {
        notificationCount++;
      });

      final loading = controller.loadDecks();
      expect(notificationCount, 1);

      // 模拟请求尚未完成，控制器就已被释放。
      controller.dispose();

      completer.complete([deck]);
      await loading;

      // 异步结果应被忽略，也不能通知已释放的监听器。
      expect(controller.decks, isEmpty);
      expect(notificationCount, 1);
    });

    test('释放后调用加载不会读取仓库', () async {
      controller.dispose();

      await controller.loadDecks();

      expect(repository.getDecksCallCount, 0);
    });
  });
}
