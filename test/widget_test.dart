import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zaiwan/features/flashcard/data/datasources/memory_flashcard_data_source.dart';
import 'package:zaiwan/features/flashcard/data/repositories/flashcard_repository_impl.dart';
import 'package:zaiwan/features/flashcard/domain/usecases/get_flashcards.dart';
import 'package:zaiwan/features/flashcard/presentation/controllers/flashcard_controller.dart';
import 'package:zaiwan/features/flashcard/presentation/pages/flashcard_page.dart';

FlashcardController createFlashcardController() {
  final dataSource = MemoryFlashcardDataSource();
  final repository = FlashcardRepositoryImpl(dataSource);
  final getFlashcards = GetFlashcards(repository);
  return FlashcardController(getFlashcards);
}

void main() {
  testWidgets('向左拖动卡片后显示答案', (tester) async {
    final controller = createFlashcardController();
    // 测试结束后释放控制器
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: FlashcardPage(controller: controller),
      )
    );

    // 等待数据加载和页面渲染完成
    await tester.pumpAndSettle();

    expect(find.text('What is the capital of France?'), findsOneWidget);
    expect(find.text('Paris'), findsNothing);
    
    // 向左拖动卡片，翻到答案面
    await tester.drag(
      find.byKey(const Key('flashcard')),
      const Offset(-250, 0),
    );

    await tester.pumpAndSettle();

    expect(find.text('Paris'), findsOneWidget);
    expect(find.text('What is the capital of France?'), findsNothing);

  });

  testWidgets('点击下一张按钮后显示第二张卡片', (tester) async {
    final controller = createFlashcardController();

    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: FlashcardPage(controller: controller),
      )
    );

    await tester.pumpAndSettle();

    // 点击下一张按钮
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();

    expect(find.text('2 / 2'), findsOneWidget);
    expect(find.text('What is 2 + 2?'), findsOneWidget);

  });
}
