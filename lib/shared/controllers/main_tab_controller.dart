import 'package:flutter/material.dart';

class MainTabController extends ChangeNotifier {
  int _index = 0;

  int get index => _index;

  void switchTo(int index) {
    if (_index == index) return;
    _index = index;
    notifyListeners();
  }
}
