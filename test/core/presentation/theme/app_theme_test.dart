import 'package:flutter_test/flutter_test.dart';

import 'package:zaiwan/core/presentation/theme/app_colors.dart';
import 'package:zaiwan/core/presentation/theme/app_theme.dart';
import 'package:zaiwan/core/presentation/theme/zaiwan_colors.dart';

/// 验证应用亮色主题的颜色映射
void main() {
  group('AppTheme.light', () {
    test('使用正确的品牌基础颜色', () {
      final theme = AppTheme.light;

      expect(theme.colorScheme.primary, AppColors.cobaltBlue);
      expect(theme.colorScheme.secondary, AppColors.warmOrange);
      expect(theme.colorScheme.surface, AppColors.white);
      expect(theme.colorScheme.onSurface, AppColors.darkNavy);
      expect(theme.scaffoldBackgroundColor, AppColors.warmWhite);
    });

    test('注册再玩产品语义颜色', () {
      final theme = AppTheme.light;

      // 从 ThemeData 中读取自定义主题扩展
      final zaiwanColors = theme.extension<ZaiwanColors>();

      expect(zaiwanColors, isNotNull);
      expect(zaiwanColors!.flashcardQuestion, AppColors.paleBlue);
      expect(zaiwanColors.flashcardAnswer, AppColors.cream);
      expect(zaiwanColors.reward, AppColors.warmOrange);
      expect(zaiwanColors.locked, AppColors.warmOrange);
      expect(zaiwanColors.unlocked, AppColors.successGreen);
    });
  });
}
