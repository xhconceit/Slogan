import 'package:flutter/material.dart';

import 'zaiwan_colors.dart';

/// 为 BuildContext 提供统一的主题读取入口
extension ThemeContextExtensions on BuildContext {
  /// 获取 Material 标题颜色
  ColorScheme get colors {
    return Theme.of(this).colorScheme;
  }

  /// 获取应用文字主题
  /// 
  TextTheme get textStyles {
    return Theme.of(this).textTheme;
  }

  /// 获取 再玩 产品语义颜色
  ZaiwanColors get zaiwanColors {
    final colors = Theme.of(this).extension<ZaiwanColors>();
    assert(colors != null,'ZaiwanColors 没有注册到 ThemeData.extensions');
    return colors!;
  }
}