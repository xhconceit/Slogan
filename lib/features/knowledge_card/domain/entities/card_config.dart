import 'card_type.dart';

/// 所有卡片专属配置的共同接口。
///
/// 每一种配置必须明确自己对应的卡片类型
abstract base class CardConfig {
  const CardConfig();

  /// 当前配置对应的卡片类型
  CardType get type;
}
