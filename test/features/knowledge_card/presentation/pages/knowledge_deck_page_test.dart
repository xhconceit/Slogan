import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaiwan/features/knowledge_card/domain/entities/knowledge_deck.dart';
import 'package:zaiwan/features/knowledge_card/domain/repositories/knowledge_deck_repository.dart';
import 'package:zaiwan/features/knowledge_card/domain/usecases/get_knowledge_decks.dart';
import 'package:zaiwan/features/knowledge_card/domain/usecases/save_knowledge_deck.dart';
import 'package:zaiwan/features/knowledge_card/presentation/controllers/create_knowledge_deck_controller.dart';
import 'package:zaiwan/features/knowledge_card/presentation/controllers/knowledge_deck_controller.dart';
import 'package:zaiwan/features/knowledge_card/presentation/pages/knowledge_deck_page.dart';

/// 测试专用仓库。
///
/// 通过修改 onGetDecks 模拟成功、失败或等待中的请求。
class FakeKnowledgeDeckRepository implements KnowledgeDeckRepository {
  Future<List<KnowledgeDeck>> Function() onGetDecks = () async =>
      <KnowledgeDeck>[];

  final List<KnowledgeDeck> savedDecks = [];

  Future<void> Function(KnowledgeDeck deck)? onSaveDeck;

  int getDecksCallCount = 0;
  int saveDeckCallCount = 0;

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
  Future<void> saveDeck(KnowledgeDeck deck) async {
    saveDeckCallCount++;

    final saveCallback = onSaveDeck;
    if (saveCallback != null) {
      await saveCallback(deck);
      return;
    }

    savedDecks.add(deck);
  }

  @override
  Future<void> deleteDeck(String id) {
    throw UnimplementedError();
  }
}

void main() {
  late FakeKnowledgeDeckRepository repository;
  late KnowledgeDeckController controller;
  late CreateKnowledgeDeckController createController;
  late KnowledgeDeck deck;

  setUp(() {
    // 每个测试使用独立的仓库和控制器。
    repository = FakeKnowledgeDeckRepository();
    controller = KnowledgeDeckController(GetKnowledgeDecks(repository));
    createController = CreateKnowledgeDeckController(
      SaveKnowledgeDeck(repository),
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
    addTearDown(createController.dispose);
  });

  /// 为页面提供 Material 主题和导航等基础环境。
  Widget createTestApp() {
    return MaterialApp(
      home: KnowledgeDeckPage(
        controller: controller,
        createController: createController,
      ),
    );
  }

  testWidgets('加载期间显示进度，并禁用刷新按钮', (tester) async {
    // 手动控制请求完成时间，以便观察加载中的界面。
    final completer = Completer<List<KnowledgeDeck>>();
    repository.onGetDecks = () => completer.future;

    await tester.pumpWidget(createTestApp());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final refreshButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.refresh),
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

  testWidgets('填写表单后创建知识库并刷新列表', (tester) async {
    repository.onGetDecks = () async =>
        List<KnowledgeDeck>.of(repository.savedDecks);

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('新建知识库'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));

    await tester.enterText(find.byType(TextField).at(0), '  Flutter  ');
    await tester.enterText(find.byType(TextField).at(1), '  Flutter 学习卡片  ');

    await tester.tap(find.text('创建'));
    await tester.pumpAndSettle();

    expect(repository.savedDecks, hasLength(1));
    expect(repository.savedDecks.single.name, 'Flutter');
    expect(repository.savedDecks.single.description, 'Flutter 学习卡片');

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('Flutter 学习卡片'), findsOneWidget);
  });

  testWidgets('名称为空时不保存，并保持创建对话框', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('新建知识库'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '   ');

    await tester.tap(find.text('创建'));
    await tester.pumpAndSettle();

    expect(repository.savedDecks, isEmpty);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('请输入知识库名称'), findsOneWidget);
  });

  testWidgets('保存期间禁用表单和按钮，防止重复提交', (tester) async {
    final saveCompleter = Completer<void>();

    repository.onSaveDeck = (deck) async {
      await saveCompleter.future;
      repository.savedDecks.add(deck);
    };
    repository.onGetDecks = () async =>
        List<KnowledgeDeck>.of(repository.savedDecks);

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('新建知识库'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Flutter');

    await tester.tap(find.text('创建'));

    // 只推进一帧，不等待尚未完成的保存操作。
    await tester.pump();

    expect(repository.saveDeckCallCount, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    final fields = tester.widgetList<TextField>(find.byType(TextField));
    expect(fields.every((field) => field.enabled == false), isTrue);

    final createButton = tester.widget<FilledButton>(find.byType(FilledButton));
    final cancelButton = tester.widget<TextButton>(find.byType(TextButton));

    expect(createButton.onPressed, isNull);
    expect(cancelButton.onPressed, isNull);

    saveCompleter.complete();
    await tester.pumpAndSettle();

    expect(repository.saveDeckCallCount, 1);
    expect(repository.savedDecks, hasLength(1));
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('保存失败时保留表单并显示重试提示', (tester) async {
    repository.onSaveDeck = (deck) async {
      throw StateError('模拟保存失败');
    };

    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('新建知识库'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Flutter');
    await tester.enterText(find.byType(TextField).at(1), '学习描述');

    await tester.tap(find.text('创建'));
    await tester.pumpAndSettle();

    expect(repository.saveDeckCallCount, 1);
    expect(repository.savedDecks, isEmpty);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('创建知识库失败，请重试'), findsOneWidget);

    final nameField = tester.widget<TextField>(find.byType(TextField).at(0));
    final descriptionField = tester.widget<TextField>(
      find.byType(TextField).at(1),
    );

    expect(nameField.controller?.text, 'Flutter');
    expect(descriptionField.controller?.text, '学习描述');

    final createButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '创建'),
    );
    final cancelButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, '取消'),
    );

    expect(createButton.onPressed, isNotNull);
    expect(cancelButton.onPressed, isNotNull);
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
