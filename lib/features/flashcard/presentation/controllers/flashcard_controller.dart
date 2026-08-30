import 'package:flutter/foundation.dart';

import '../../domain/entities/flashcard.dart';
import '../../domain/usecases/get_flashcards.dart';

final class FlashcardController extends ChangeNotifier {
  FlashcardController(this.getFlashcards);

  final GetFlashcards getFlashcards;

  bool _isLoading = false;
  List<Flashcard> _flashcards = const [];
  Object? _error;

  bool get isLoading => _isLoading;
  List<Flashcard> get flashcards => _flashcards;
  Object? get error => _error;

  Future<void> loadFlashcards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _flashcards = await getFlashcards();
    } catch (error) {
      _error = error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
