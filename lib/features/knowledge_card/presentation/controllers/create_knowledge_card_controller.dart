import 'package:flutter/foundation.dart';

import '../../domain/usecases/save_knowledge_card.dart';
import '../../domain/entities/knowledge_card.dart';
import '../../domain/entities/question_answer_card_config.dart';

/// 管理新建卡片表单的保存状态
///
/// 页面负责收集问题和答案
/// 控制器负责组装卡片，再交给保存用例处理
final class CreateKnowledgeCardController extends ChangeNotifier {
  CreateKnowledgeCardController({
    required this.deckId,
    required SaveKnowledgeCard saveKnowledgeCard,
  }) : _saveKnowledgeCard = saveKnowledgeCard;

  /// 新卡片所属的知识库
  ///
  /// 打开表单时确定，避免保存时把卡片放进其他知识库
  final String deckId;

  /// 从外部传入保存用例，复用应用已有的卡片仓库。
  final SaveKnowledgeCard _saveKnowledgeCard;

  /// 保存期间为 true,用来禁用提交按钮，防止重复操作。
  bool _isSaving = false;

  /// 最近一次保存错误；null 表示没有错误
  Object? _error;

  /// 标记控制器是否已释放
  ///
  /// 异步保存结束后，用它判断是否还能通知页面
  bool _isDisposed = false;

  /// 页面通过 getter 读取状态，不能直接修改内部字段
  bool get isSaving => _isSaving;
  Object? get error => _error;

  /// 创建一张问答卡
  ///
  /// id 由打开表单的一方生成
  /// 同一次创建失败后重试，应继续使用同一个 ID
  /// 避免重复生成卡片
  ///
  /// 返回 true 表示保存成功
  /// 返回 false 表示失败，重复提交或控制器已释放
  Future<bool> createQuestionAnswerCard({
    required String id,
    required String prompt,
    required String answer,
  }) async {
    /// 正在保存时忽略重复提交，释放后也不再启动保存
    if (_isSaving || _isDisposed) {
      return false;
    }

    // 开始保存，清除上次的错误，并通知页面更新按钮状态
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      /// 清理输入内容两端的空白，保留正文中的换行和空格
      final normalizedPrompt = prompt.trim();
      final normalizedAnswer = answer.trim();

      /// 现有保存用例会检查题面，但不会检查问答卡答案
      /// 在创建表单流程中拒绝空答案，提示用户补充内容

      if (normalizedAnswer.isEmpty) {
        throw ArgumentError.value(answer, 'answer', '答案不能为空');
      }

      // 新卡片的创建时间和更新时间一致
      final now = DateTime.now();

      // 通用信息放在 KnowledgeCard 中
      // 问答卡特有的答案放在 QuestionAnswerCardConfig 中
      final card = KnowledgeCard(
        id: id,
        deckId: deckId,
        prompt: normalizedPrompt,
        config: QuestionAnswerCardConfig(answer: normalizedAnswer),
        createdAt: now,
        updatedAt: now,
      );

      // 复用已有用例，检查 ID、题面和时间等通用字段，
      // 校验通过后再交给仓库保存。
      await _saveKnowledgeCard(card);

      // 保存成功不代表页面仍然存在。
      // 页面收到结果后，需要检查 mounted 再关闭表单或刷新。
      return true;
    } catch (error) {
      // 校验失败或仓库保存失败，都会进入这里。
      // 控制器只记录错误，输入内容仍由表单保留。
      if (!_isDisposed) {
        _error = error;
      }

      return false;
    } finally {
      // 无论成功还是失败，都结束保存状态。
      _isSaving = false;

      // 保存期间页面可能已关闭，释放后不能再通知监听者。
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    // 页面关闭后，不再向监听者发送状态通知
    _isDisposed = true;

    // 清理 ChangeNotifier 的监听资源
    super.dispose();
  }
}
