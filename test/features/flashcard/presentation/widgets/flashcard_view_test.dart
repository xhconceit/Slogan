import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zaiwan/core/presentation/theme/app_theme.dart';
import 'package:zaiwan/features/flashcard/presentation/widgets/flashcard_view.dart';

/// 创建包含完整主题的闪卡组件测试环境
Widget createTestApp() {
  return MaterialApp(
    theme: AppTheme.light,
    home: const Scaffold(
      body: Center(
        child: FlashcardView(
          question: 'What is the capital of France?',
          answer: 'Paris',
        ),
      ),
    ),
  );
}

/// 验证闪卡组件的拖动翻转行为
void main() {
  testWidgets('默认显示问题面', (tester) async {
    await tester.pumpWidget(createTestApp());

    expect(find.text('What is the capital of France?'), findsOneWidget);
    expect(find.text('Paris'), findsNothing);
  });

  testWidgets('向左拖动超过一半后显示答案面', (tester) async {
    await tester.pumpWidget(createTestApp());

    // 缓慢向左拖动超过卡片宽度的一半
    await tester.timedDrag(
      find.byKey(const Key('flashcard')),
      const Offset(-250, 0),
      const Duration(milliseconds: 600),
    );
    await tester.pumpAndSettle();

    expect(find.text('Paris'), findsOneWidget);
    expect(find.text('What is the capital of France?'), findsNothing);
  });

  testWidgets('拖动不足一半后返回问题面', (tester) async {
    await tester.pumpWidget(createTestApp());

    // 缓慢拖动较短距离，避免触发快速滑动
    await tester.timedDrag(
      find.byKey(const Key('flashcard')),
      const Offset(-100, 0),
      const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();

    expect(find.text('What is the capital of France?'), findsOneWidget);
    expect(find.text('Paris'), findsNothing);
  });
}
