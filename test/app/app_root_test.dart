import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zaiwan/app/dependency_injection.dart';
import 'package:zaiwan/main.dart';

void main() {
  testWidgets('移除 AppRoot 时关闭数据库连接', (tester) async {
    final dependencies = AppDependencies.create();
    var closeDatabaseCallCount = 0;

    await tester.pumpWidget(
      AppRoot(
        dependencies: dependencies,
        closeDatabase: () async {
          closeDatabaseCallCount++;
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(closeDatabaseCallCount, 0);

    // 使用另一个组件替换 AppRoot，触发它的 dispose。
    await tester.pumpWidget(const SizedBox());
    await tester.pump();

    expect(closeDatabaseCallCount, 1);
  });
}
