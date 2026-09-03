import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zaiwan/core/presentation/theme/app_theme.dart';
import 'package:zaiwan/features/flashcard/data/datasources/memory_flashcard_data_source.dart';
import 'package:zaiwan/features/flashcard/data/repositories/flashcard_repository_impl.dart';
import 'package:zaiwan/features/flashcard/domain/usecases/get_flashcards.dart';
import 'package:zaiwan/features/flashcard/presentation/controllers/flashcard_controller.dart';
import 'package:zaiwan/features/flashcard/presentation/pages/flashcard_page.dart';

/// 创建使用内存数据源的闪卡控制器
FlashcardController createFlashcardController() {
  final dataSource = MemoryFlashcardDataSource();
  final repository = FlashcardRepositoryImpl(dataSource);
  final getFlashcards = GetFlashcards(repository);

  return FlashcardController(getFlashcards);
}

/// 创建包含完整主题环境的测试应用
Widget createTestApp(FlashcardController controller) {
  return MaterialApp(
    theme: AppTheme.light,
    home: FlashcardPage(controller: controller),
  );
}

/// 验证闪卡页面的核心交互
void main() {
  testWidgets('点击下一张按钮后显示第二张卡片', (tester) async {
    final controller = createFlashcardController();

    // 测试结束后释放控制器
    addTearDown(controller.dispose);

    await tester.pumpWidget(createTestApp(controller));

    await tester.pumpAndSettle();

    // 点击下一张按钮
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();

    expect(find.text('2 / 2'), findsOneWidget);
    expect(find.text('What is 2 + 2?'), findsOneWidget);
  });
}
