import 'package:flutter/foundation.dart';

import '../../domain/entities/knowledge_deck.dart';
import '../../domain/usecases/save_knowledge_deck.dart';

/// 管理 新建知识库 表单的保存状态
///
/// 页面提供输入内容，控制器组装实体
/// 再交给 SaveKnowledgeDeck 校验并保存。

final class CreateKnowledgeDeckController extends ChangeNotifier {
  CreateKnowledgeDeckController(this._saveKnowledgeDeck);

  final SaveKnowledgeDeck _saveKnowledgeDeck;

  bool _isSaving = false;
  Object? _error;
  bool _isDisposed = false;

  /// 是否正在保存
  ///
  /// 页面可以据提交按钮并显示进度。
  bool get isSaving => _isSaving;

  /// 最近一次保存错误
  ///
  /// 保存失败时保留表单，让用户修改或重试
  Object? get error => _error;

  /// 创建知识库
  ///
  /// id 由外部提供必须是新知识库的唯一标识
  /// 同一次创建失败后重试，应该继续使用同一个 id
  ///
  /// 返回 true 表示保存成功
  /// 返回 false 表示失败，重复提交或控制器已释放
  Future<bool> createDeck({
    required String id,
    required String name,
    String? description,
  }) async {
    // 防止用户连续点击造成重复提交
    if (_isSaving || _isDisposed) {
      return false;
    }
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      // 名称和描述去掉首尾空白
      final normalizedName = name.trim();
      final normalizedDescription = description?.trim();

      // 新建时创建时间与更新时间相同
      final now = DateTime.now();

      final deck = KnowledgeDeck(
        id: id,
        name: normalizedName,
        // 没填描述时使用 null 统一表示 没有描述
        description:
            normalizedDescription == null || normalizedDescription.isEmpty
            ? null
            : normalizedDescription,
        createdAt: now,
        updatedAt: now,
      );

      /// 复用已有业务校验
      // ID 名称不能为空，更新时间不能早于创建时间
      ///
      // 校验或底层保存抛出的错误都会接入 error
      await _saveKnowledgeDeck(deck);

      // 保存成功与页面是否依然存在时两回事
      // 页面收到结果后还要检查 mounted 在执行导航
      return true;
    } catch (error) {
      if (!_isDisposed) {
        _error = error;
      }
      return false;
    } finally {
      // 无论成功还是失败，都结束保存状态
      _isSaving = false;

      // 页面关闭后，不能在通知已释放的监听
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
