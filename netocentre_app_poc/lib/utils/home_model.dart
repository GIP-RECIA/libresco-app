import 'package:flutter/material.dart';

class HomeModel with ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}
