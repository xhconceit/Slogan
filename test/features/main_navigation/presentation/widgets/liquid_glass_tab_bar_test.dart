import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaiwan/features/main_navigation/presentation/models/main_navigation_item.dart';
import 'package:zaiwan/features/main_navigation/presentation/widgets/liquid_glass_tab_bar.dart';

Future<void> mountBar(
  WidgetTester tester,
  List<int> selections, {
  TextDirection direction = TextDirection.ltr,
}) async {
  var index = 0;
  await tester.pumpWidget(
    CupertinoApp(
      home: Directionality(
        textDirection: direction,
        child: StatefulBuilder(
          builder: (context, setState) => Align(
            alignment: Alignment.bottomCenter,
            child: LiquidGlassTabBar(
              items: mainNavigationItems,
              currentIndex: index,
              onTap: (value) {
                selections.add(value);
                setState(() => index = value);
              },
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder get capsuleTransform => find.descendant(
  of: find.byType(AnimatedPositioned),
  matching: find.byType(Transform),
);

void main() {
  testWidgets('点击标签只触发一次切换', (tester) async {
    final selections = <int>[];
    await mountBar(tester, selections);
    await tester.tap(find.text('闪卡'));
    await tester.pumpAndSettle();
    expect(selections, [1]);
  });

  for (final direction in TextDirection.values) {
    testWidgets('拖动松手才切换并恢复形状：${direction.name}', (tester) async {
      final selections = <int>[];
      await mountBar(tester, selections, direction: direction);
      final start = tester.getCenter(find.text('今日'));
      final end = tester.getCenter(find.text('我的'));
      final gesture = await tester.startGesture(start);
      await gesture.moveTo(Offset.lerp(start, end, 0.5)!);
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.moveTo(end);
      await tester.pump(const Duration(milliseconds: 200));

      expect(selections, isEmpty);
      final pressed = tester.widget<Transform>(capsuleTransform).transform;
      expect(pressed.entry(0, 0), greaterThan(1));
      expect(pressed.entry(1, 1), lessThan(1));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(selections, [2]);
      final released = tester.widget<Transform>(capsuleTransform).transform;
      expect(released.entry(0, 0), closeTo(1, 0.001));
      expect(released.entry(1, 1), closeTo(1, 0.001));
    });
  }

  testWidgets('取消拖动保持当前标签并允许下一次点击', (tester) async {
    final selections = <int>[];
    await mountBar(tester, selections);
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('今日')),
    );
    await gesture.moveTo(tester.getCenter(find.text('我的')));
    await tester.pump(const Duration(milliseconds: 200));
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(selections, isEmpty);
    expect(
      tester.widget<AnimatedPositioned>(find.byType(AnimatedPositioned)).left,
      0,
    );
    expect(
      tester.widget<Transform>(capsuleTransform).transform.entry(0, 0),
      closeTo(1, 0.001),
    );
    await tester.tap(find.text('闪卡'));
    await tester.pumpAndSettle();
    expect(selections, [1]);
  });
}
