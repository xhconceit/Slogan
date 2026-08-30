import 'package:flutter/material.dart';

/// 保存设计稿中的原生品牌颜色
/// 
/// 页面不应该直接用这个类
/// 原始颜色应先在 AppTheme 中转换成语义化颜色
final class AppColors {
  AppColors._();

  // 品牌钴蓝
  static const cobaltBlue = Color(0xFF2F64C5);
  // 奖励暖橙
  static const warmOrange = Color(0xFFE87448);
  // 页面暖白背景
  static const warmWhite = Color(0xFFF8F6F1);
  /// 卡片白色
  static const white = Color(0xFFFFFFFF);
  /// 浅蓝辅助色
  static const paleBlue = Color(0xFFE7EEFB);
  /// 奶油辅助色
  static const cream = Color(0xFFFFF0CF);

    /// 主要文字深蓝
  static const darkNavy = Color(0xFF1F2E46);

  /// 次要文字蓝灰
  static const blueGray = Color(0xFF68778D);

  /// 成功状态颜色
  static const successGreen = Color(0xFF2E7D5B);

  /// 错误状态颜色
  static const errorRed = Color(0xFFBA1A1A);
}
