import 'package:flutter/foundation.dart';

import '../../domain/entities/knowledge_deck.dart';
import '../../domain/usecases/get_knowledge_decks.dart';

/// 管理知识库列表的状态
///
/// 页面负责展示；控制器负责调用业务用例并通知页面更新
final class KnowledgeDeckController extends ChangeNotifier {
  /// 从外部接收业务用例，避免在控制器内部创建仓库或数据源
  KnowledgeDeckController(this._getKnowledgeDecks);

  final GetKnowledgeDecks _getKnowledgeDecks;

  /// 以下字段只能在当前文件内直接访问
  /// 页面通过下面的 getter 读取状态
  bool _isLoading = false;
  List<KnowledgeDeck> _decks = const [];
  Object? _error;

  // 标记控制器是否已经释放
  // 异步加载完成时，控制器可能已经不在使用
  bool _isDisposed = false;

  /// 是否正在加载，用于显示加载提示
  bool get isLoading => _isLoading;

  /// 当前知识库列表
  ///
  /// 加载成功后会保存为不可修改的列表
  /// 防止页面直接增删数据而绕过控制器
  List<KnowledgeDeck> get decks => _decks;

  /// 最近一次加载的错误； null 表示没有错误
  Object? get error => _error;

  /// 加载知识库列表，也可以用于刷新或失败后重试
  Future<void> loadDecks() async {
    /// 加载期间忽略重复请求；释放后也不再发起请求
    if (_isLoading || _isDisposed) {
      return;
    }

    // 开始加载前清除上次错误
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      /// 调用业务用例，等待知识库列表返回
      final decks = await _getKnowledgeDecks();

      /// 等待期间如果控制器已释放，就忽略结果
      if (_isDisposed) {
        return;
      }

      _decks = List<KnowledgeDeck>.unmodifiable(decks);
    } catch (error) {
      /// 保存错误，让页面决定如何展示失败提示
      /// 保留上次成功夹杂的列表，避免刷新失败时清空内容
      if (!_isDisposed) {
        _error = error;
      }
    } finally {
      /// 无论成功还是失败，都结束
      // 已释放的控制器不能在通知页面
      _isLoading = false;
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  /// 由持有这个控制器的对象在不再使用时调用
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
