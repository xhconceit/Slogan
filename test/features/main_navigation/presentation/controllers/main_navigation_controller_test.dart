import 'package:flutter_test/flutter_test.dart';
import 'package:zaiwan/features/main_navigation/presentation/controllers/main_navigation_controller.dart';

void main() {
  test('默认选中今日页面', () {
    final controller = MainNavigationController();
    addTearDown(controller.dispose);

    expect(controller.destination, MainNavigationDestination.home);
    expect(controller.selectedIndex, 0);
  });

  test('选择新的导航项后更新状态并通知监听者', () {
    final controller = MainNavigationController();
    addTearDown(controller.dispose);
    var notificationCount = 0;
    controller.addListener(() => notificationCount++);

    controller.selectIndex(1);

    expect(controller.destination, MainNavigationDestination.flashcards);
    expect(notificationCount, 1);
  });

  test('重复选择当前导航项时不重复通知', () {
    final controller = MainNavigationController();
    addTearDown(controller.dispose);
    var notificationCount = 0;
    controller.addListener(() => notificationCount++);

    controller.selectIndex(0);

    expect(notificationCount, 0);
  });
}
