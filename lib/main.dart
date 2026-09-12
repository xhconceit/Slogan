import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/dependency_injection.dart';

void main() {
  final appDependencies = AppDependencies.create();
  runApp(ZaiwanApp(dependencies: appDependencies));
}

/// 应用依赖的持有者
///
/// 创建和释放放在同一个对象中，明确生命周期
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late final AppDependencies _dependencies;

  @override
  void initState() {
    super.initState();

    /// 跟构建创建时只执行一次
    _dependencies = AppDependencies.create();
  }

  @override
  Widget build(BuildContext context) {
    // 重建时继续使用同一组依赖
    return ZaiwanApp(dependencies: _dependencies);
  }

  @override
  void dispose() {
    // 根组件被移除时，释放它拥有的控制器
    _dependencies.dispose();
    super.dispose();
  }
}
