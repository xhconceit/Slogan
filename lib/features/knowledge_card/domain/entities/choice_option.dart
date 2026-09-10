/// 选择题中的一个可选答案。
///
/// 使用稳定的 [id] 判断答案，避免选项重新排序后正确答案发生变化。
class ChoiceOption {
  const ChoiceOption({required this.id, required this.content});

  /// 选项的唯一标识，显示顺序改变时保持不变。
  final String id;

  /// 展示给用户的选项内容。
  final String content;
}
