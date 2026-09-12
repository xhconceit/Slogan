import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/knowledge_deck.dart';
import 'package:zaiwan/features/knowledge_card/domain/repositories/knowledge_deck_repository.dart';
import 'package:zaiwan/features/knowledge_card/domain/usecases/get_knowledge_decks.dart';
import 'package:zaiwan/features/knowledge_card/presentation/controllers/knowledge_deck_controller.dart';
import 'package:zaiwan/features/knowledge_card/presentation/pages/knowledge_deck_page.dart';

/// 测试专用仓库。
///
/// 通过修改 onGetDecks 模拟成功、失败或等待中的请求。
class FakeKnowledgeDeckRepository implements KnowledgeDeckRepository {
  Future<List<KnowledgeDeck>> Function() onGetDecks =
      () async => <KnowledgeDeck>[];

  int getDecksCallCount = 0;

  @override
  Future<List<KnowledgeDeck>> getDecks() {
    getDecksCallCount++;
    return onGetDecks();
  }

  // 页面只查询列表，其他方法不应被调用。
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
    // 每个测试使用独立的仓库和控制器。
    repository = FakeKnowledgeDeckRepository();
    controller = KnowledgeDeckController(
      GetKnowledgeDecks(repository),
    );

    final now = DateTime(2026, 9, 12);
    deck = KnowledgeDeck(
      id: 'deck-1',
      name: 'Flutter',
      description: 'Flutter 学习卡片',
      createdAt: now,
      updatedAt: now,
    );

    // 测试持有控制器，因此由测试负责释放。
    addTearDown(controller.dispose);
  });

  /// 为页面提供 Material 主题和导航等基础环境。
  Widget createTestApp() {
    return MaterialApp(
      home: KnowledgeDeckPage(controller: controller),
    );
  }

  testWidgets('加载期间显示进度，并禁用刷新按钮', (tester) async {
    // 手动控制请求完成时间，以便观察加载中的界面。
    final completer = Completer<List<KnowledgeDeck>>();
    repository.onGetDecks = () => completer.future;

    await tester.pumpWidget(createTestApp());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final refreshButton = tester.widget<IconButton>(
      find.byTooltip('刷新知识库'),
    );

    // onPressed 为 null 表示按钮被禁用。
    expect(refreshButton.onPressed, isNull);

    // 请求未完成时不要 pumpAndSettle，
    // 因为持续转动的进度动画不会稳定下来。
    completer.complete([]);
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('还没有知识库'), findsOneWidget);
  });

  testWidgets('加载成功但没有数据时显示空状态', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('知识库'), findsOneWidget);
    expect(find.text('还没有知识库'), findsOneWidget);
    expect(find.text('重新加载'), findsNothing);
    expect(repository.getDecksCallCount, 1);
  });

  testWidgets('加载成功后显示知识库名称和描述', (tester) async {
    repository.onGetDecks = () async => [deck];

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('Flutter 学习卡片'), findsOneWidget);
    expect(find.text('还没有知识库'), findsNothing);
  });

  testWidgets('首次加载失败显示错误，点击重试后展示数据', (tester) async {
    repository.onGetDecks = () async {
      throw StateError('模拟读取失败');
    };

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('知识库加载失败，请重试'), findsOneWidget);
    expect(find.text('重新加载'), findsOneWidget);
    expect(find.text('还没有知识库'), findsNothing);

    // 模拟数据源恢复，然后通过真实按钮触发重试。
    repository.onGetDecks = () async => [deck];

    await tester.tap(find.text('重新加载'));
    await tester.pumpAndSettle();

    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('知识库加载失败，请重试'), findsNothing);
    expect(repository.getDecksCallCount, 2);
  });

  testWidgets('刷新失败保留旧列表，并显示刷新失败提示', (tester) async {
    // 首次加载成功。
    repository.onGetDecks = () async => [deck];

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Flutter'), findsOneWidget);

    // 随后的刷新失败。
    repository.onGetDecks = () async {
      throw StateError('模拟刷新失败');
    };

    await tester.tap(find.byTooltip('刷新知识库'));
    await tester.pumpAndSettle();

    // 已有内容仍然可见，不应被整页错误提示替换。
    expect(find.text('Flutter'), findsOneWidget);
    expect(find.textContaining('刷新失败，当前显示上次加载的内容'), findsOneWidget);
    expect(find.text('知识库加载失败，请重试'), findsNothing);
    expect(repository.getDecksCallCount, 2);
  });
}
