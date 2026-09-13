import 'package:flutter/foundation.dart';

import '../../domain/entities/knowledge_deck.dart';
import '../../domain/usecases/delete_knowledge_deck.dart';
import '../../domain/usecases/save_knowledge_deck.dart';

/// 管理知识库编辑与删除操作的状态。
final class ManageKnowledgeDeckController extends ChangeNotifier {
  ManageKnowledgeDeckController({
    required SaveKnowledgeDeck saveKnowledgeDeck,
    required DeleteKnowledgeDeck deleteKnowledgeDeck,
  }) : _saveKnowledgeDeck = saveKnowledgeDeck,
       _deleteKnowledgeDeck = deleteKnowledgeDeck;

  final SaveKnowledgeDeck _saveKnowledgeDeck;
  final DeleteKnowledgeDeck _deleteKnowledgeDeck;

  bool _isBusy = false;
  Object? _error;
  bool _isDisposed = false;

  bool get isBusy => _isBusy;
  Object? get error => _error;

  Future<bool> updateDeck({
    required KnowledgeDeck deck,
    required String name,
    String? description,
  }) async {
    final normalizedDescription = description?.trim();
    return _run(() {
      return _saveKnowledgeDeck(
        KnowledgeDeck(
          id: deck.id,
          name: name.trim(),
          description:
              normalizedDescription == null || normalizedDescription.isEmpty
              ? null
              : normalizedDescription,
          createdAt: deck.createdAt,
          updatedAt: DateTime.now(),
        ),
      );
    });
  }

  Future<bool> deleteDeck(String deckId) {
    return _run(() => _deleteKnowledgeDeck(deckId));
  }

  Future<bool> _run(Future<void> Function() operation) async {
    if (_isBusy || _isDisposed) return false;

    _isBusy = true;
    _error = null;
    notifyListeners();

    try {
      await operation();
      return true;
    } catch (error) {
      if (!_isDisposed) _error = error;
      return false;
    } finally {
      _isBusy = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
