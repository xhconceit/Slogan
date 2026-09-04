import "package:flutter/foundation.dart";

enum MainNavigationDestination {
  home,
  flashcards,
  profile,
}

final class MainNavigationController extends ChangeNotifier {
  MainNavigationDestination _destination = MainNavigationDestination.home;

  MainNavigationDestination get destination => _destination;

  int get selectedIndex => _destination.index;

  void selectIndex(int index) {
    final next = MainNavigationDestination.values[index];
    if (next == _destination) {
      return;
    }

    _destination = next;
    notifyListeners();
  }

}