import 'package:flutter/material.dart';

class ErrorState extends ChangeNotifier {
  String? _message;
  String? _actionLabel;
  VoidCallback? _actionCallback;

  String? get message => _message;
  String? get actionLabel => _actionLabel;
  VoidCallback? get actionCallback => _actionCallback;
  bool get hasError => _message != null;

  void setError(String message, {String? actionLabel, VoidCallback? onAction}) {
    _message = message;
    _actionLabel = actionLabel;
    _actionCallback = onAction;
    notifyListeners();
  }

  void clearError() {
    _message = null;
    _actionLabel = null;
    _actionCallback = null;
    notifyListeners();
  }
}
