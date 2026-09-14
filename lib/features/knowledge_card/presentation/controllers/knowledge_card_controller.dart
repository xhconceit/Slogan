import 'package:flutter/foundation.dart';

import '../../domain/entities/knowledge_card.dart';
import '../../domain/usecases/get_knowledge_cards_by_deck_id.dart';

/// 管理一个知识库中的卡片列表
final class KnowledgeCardController extends ChangeNotifier {
  KnowledgeCardController({
    required this.deckId,
    required GetKnowledgeCardsByDeckId getKnowledgeCardsByDeckId,
  }) : _getKnowledgeCardsByDeckId = getKnowledgeCardsByDeckId;

  final String deckId;
  final GetKnowledgeCardsByDeckId _getKnowledgeCardsByDeckId;

  List<KnowledgeCard> _cards = const [];
  bool _isLoading = false;
  Object? _error;

  List<KnowledgeCard> get cards => _cards;
  bool get isLoading => _isLoading;
  Object? get error => _error;

  /// 标记控制器是否已经释放。
  ///
  /// 用户退出页面时，查询可能还没结束。
  /// 查询返回后需要检查这个标记，避免通知已经退出的页面。
  bool _isDisposed = false;

  /// 加载当前知识库中的卡片。
  ///
  /// 首次进入页面、手动刷新和失败重试，都可以调用这个方法。
  Future<void> loadCards() async {
    // 正在加载时忽略重复请求。
    // 控制器释放后，也不再发起新的查询。
    if (_isLoading || _isDisposed) {
      return;
    }

    // 开始一次新的加载，清除上次的错误。
    // 保留旧卡片，让刷新期间仍然可以展示已有内容。
    _isLoading = true;
    _error = null;
    // 通知监听者状态发生变化，页面可以显示加载提示。
    notifyListeners();
    try {
      // 调用业务用例，查询属于当前知识库的卡片。
      // await 等待查询完成，但不会阻塞界面操作。
      final cards = await _getKnowledgeCardsByDeckId(deckId);
      // 等待期间用户可能已经退出页面。
      // 如果控制器已释放，就忽略查询结果。
      if (_isDisposed) {
        return;
      }

      // 保存查询结果，并禁止外部直接增删这个列表。
      // 页面通过 cards getter 读取数据。
      _cards = List<KnowledgeCard>.unmodifiable(cards);
    } catch (error) {
      // 查询失败时记录错误，交给页面决定如何提示用户。
      // 不清空旧卡片，避免刷新失败后已有内容消失。
      if (!_isDisposed) {
        _error = error;
      }
    } finally {
      // 无论查询成功、失败，还是在 try 中提前 return，
      // 都会执行 finally，结束本次加载。
      _isLoading = false;

      // 控制器释放后不能再调用 notifyListeners。
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  /// 由持有控制器的对象在不再使用它时调用。
  @override
  void dispose() {
    // 先标记为已释放，让尚未完成的查询忽略返回结果。
    _isDisposed = true;
    // 调用父类方法，清理 ChangeNotifier 的监听资源。
    super.dispose();
  }
}
