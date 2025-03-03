import 'package:flutter/material.dart';

class LoadingState extends ChangeNotifier {
  String _message = 'Loading data...';
  bool _isVisible = false;

  String get message => _message;
  bool get isVisible => _isVisible;

  void startLoading(String message) {
    _message = message;
    _isVisible = true;
    notifyListeners();
  }

  void stopLoading() {
    _isVisible = false;
    notifyListeners();
  }
}
