import 'package:flutter/material.dart';

import 'dart:async';

import 'app/app.dart';
import 'app/dependency_injection.dart';
import 'core/data/database/app_database.dart';
import 'features/knowledge_card/data/datasources/sqlite_knowledge_deck_data_source.dart';

Future<void> main() async {
  // sqflife 在打开数据库前需要确保 Flutter 引擎已经初始化。
  WidgetsFlutterBinding.ensureInitialized();

  // 打开应用的持久化 SQLite 数据库
  final database = await AppDatabase.open();

  /// 将 SQLite 数据源注入知识库功能
  final appDependencies = AppDependencies.create(
    knowledgeDeckDataSource: SqliteKnowledgeDeckDataSource(database),
  );
  runApp(AppRoot(dependencies: appDependencies, closeDatabase: database.close));
}

/// 应用依赖的持有者
///
/// 创建和释放放在同一个对象中，明确生命周期
class AppRoot extends StatefulWidget {
  const AppRoot({
    required this.dependencies,
    required this.closeDatabase,
    super.key,
  });

  final AppDependencies dependencies;

  /// 关闭当前应用持有的数据库连接
  final Future<void> Function() closeDatabase;

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  @override
  Widget build(BuildContext context) {
    // 重建时继续使用根组件持有的同一组依赖。
    return ZaiwanApp(dependencies: widget.dependencies);
  }

  @override
  void dispose() {
    // 先释放使用数据库的控制器，避免产生新的读写请求
    widget.dependencies.dispose();

    // State.dispose 不能声明为 async
    // 使用 unawaited 启动数据库关闭操作。
    unawaited(widget.closeDatabase());

    // 根组件被移除时，释放它拥有的控制器
    super.dispose();
  }
}
