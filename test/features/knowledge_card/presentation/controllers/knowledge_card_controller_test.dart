import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/knowledge_card.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/question_answer_card_config.dart';
import 'package:zaiwan/features/knowledge_card/domain/repositories/knowledge_card_repository.dart';
import 'package:zaiwan/features/knowledge_card/domain/usecases/get_knowledge_cards_by_deck_id.dart';
import 'package:zaiwan/features/knowledge_card/presentation/controllers/knowledge_card_controller.dart';

/// 测试专用仓库，不访问真实数据库。
///
/// 用 Completer 控制查询完成的时机，
/// 这样就能检查“正在加载”和“加载完成”两个阶段。
final class FakeKnowledgeCardRepository
    implements KnowledgeCardRepository {
  final completer = Completer<List<KnowledgeCard>>();

  /// 记录收到的知识库 ID，检查控制器有没有传对参数。
  String? requestedDeckId;

  @override
  Future<List<KnowledgeCard>> getCardsByDeckId(String deckId) {
    requestedDeckId = deckId;
    return completer.future;
  }

  // 这个测试只查询列表，不应该调用下面的方法。
  // 如果误调用，就抛出异常，让测试暴露问题。
  @override
  Future<KnowledgeCard?> getCardById(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> saveCard(KnowledgeCard card) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteCard(String id) {
    throw UnimplementedError();
  }
}

void main() {
  test('加载当前知识库的卡片，并通知页面更新状态', () async {
    // 1. 准备依赖：测试仓库 → 查询用例 → 控制器。
    final repository = FakeKnowledgeCardRepository();
    final controller = KnowledgeCardController(
      deckId: 'deck-1',
      getKnowledgeCardsByDeckId: GetKnowledgeCardsByDeckId(repository),
    );

    // 测试结束后释放控制器，即使断言失败也会执行。
    addTearDown(controller.dispose);

    // 准备一张问答卡，作为查询返回的数据。
    final now = DateTime(2026, 9, 14);
    final card = KnowledgeCard(
      id: 'card-1',
      deckId: 'deck-1',
      prompt: 'Flutter 使用什么语言？',
      config: const QuestionAnswerCardConfig(answer: 'Dart'),
      createdAt: now,
      updatedAt: now,
    );

    // 记录每次通知时的加载状态，
    // 相当于模拟页面监听控制器。
    final loadingStates = <bool>[];
    controller.addListener(() {
      loadingStates.add(controller.isLoading);
    });

    // 2. 开始加载，但暂时不 await。
    // 仓库还没有返回结果，我们要先检查加载中的状态。
    final loading = controller.loadCards();

    expect(repository.requestedDeckId, 'deck-1');
    expect(controller.isLoading, isTrue);
    expect(controller.cards, isEmpty);
    expect(controller.error, isNull);
    expect(loadingStates, [true]);

    // 3. 手动让仓库返回卡片，再等待控制器处理完成。
    repository.completer.complete([card]);
    await loading;

    // 4. 加载完成后，应该保存卡片、结束加载且没有错误。
    expect(controller.cards, [card]);
    expect(controller.isLoading, isFalse);
    expect(controller.error, isNull);

    // 页面应该收到两次通知：开始加载、结束加载。
    expect(loadingStates, [true, false]);

    // 页面只能读取列表，不能绕过控制器直接清空它。
    expect(
      () => controller.cards.clear(),
      throwsUnsupportedError,
    );
  });

  test('加载失败后保存错误，并结束加载状态', () async {
    // 每个测试使用独立对象，避免查询结果互相影响。
    final repository = FakeKnowledgeCardRepository();
    final controller = KnowledgeCardController(
      deckId: 'deck-1',
      getKnowledgeCardsByDeckId: GetKnowledgeCardsByDeckId(repository),
    );
    addTearDown(controller.dispose);

    final failure = StateError('读取卡片失败');
    final loadingStates = <bool>[];
    controller.addListener(() {
      loadingStates.add(controller.isLoading);
    });

    // 先检查请求尚未完成时的状态，再模拟仓库抛出异常。
    final loading = controller.loadCards();
    expect(controller.isLoading, isTrue);
    repository.completer.completeError(failure);
    await loading;

    // 控制器应保存原始错误，并通知页面停止显示加载提示。
    expect(controller.error, same(failure));
    expect(controller.isLoading, isFalse);
    expect(controller.cards, isEmpty);
    expect(loadingStates, [true, false]);
  });

  test('加载期间释放控制器，忽略结果且不再通知页面', () async {
    final repository = FakeKnowledgeCardRepository();
    final controller = KnowledgeCardController(
      deckId: 'deck-1',
      getKnowledgeCardsByDeckId: GetKnowledgeCardsByDeckId(repository),
    );

    // 标记是否已经手动释放，让断言提前失败时也能清理资源。
    var disposed = false;
    addTearDown(() {
      if (!disposed) controller.dispose();
    });

    final now = DateTime(2026, 9, 14);
    final card = KnowledgeCard(
      id: 'card-1',
      deckId: 'deck-1',
      prompt: 'Flutter 使用什么语言？',
      config: const QuestionAnswerCardConfig(answer: 'Dart'),
      createdAt: now,
      updatedAt: now,
    );

    var notificationCount = 0;
    controller.addListener(() {
      notificationCount++;
    });

    final loading = controller.loadCards();
    expect(notificationCount, 1);

    // 模拟用户在查询完成前退出页面，由持有者释放控制器。
    controller.dispose();
    disposed = true;

    // 查询随后返回，控制器应忽略数据，且不能通知已释放的监听器。
    repository.completer.complete([card]);
    await loading;

    expect(controller.cards, isEmpty);
    expect(controller.isLoading, isFalse);
    expect(controller.error, isNull);
    expect(notificationCount, 1);
  });
}
