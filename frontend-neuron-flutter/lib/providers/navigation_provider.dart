import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  static const int home = 0;
  static const int chat = 1;
  static const int knowledge = 2;
  static const int tasks = 3;
  static const int settings = 4;
  static const int connections = 5;
  static const int timeline = 6;
  static const int reflection = 7;

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void navigateTo(int index) {
    setIndex(index);
  }
}
