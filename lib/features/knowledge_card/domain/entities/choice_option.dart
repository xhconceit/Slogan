/// 选择题中的一个可选答案。
///
/// 使用稳定的 [id] 判断答案，避免选项重新排序后正确答案发生变化
class ChoiceOption {
  const ChoiceOption({required this.id, required this.content});
  final String id;
  /// 展示给用户的选项内容
  final String content;
}
