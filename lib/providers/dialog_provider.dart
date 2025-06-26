import 'package:flutter/material.dart';

class DialogProvider extends ChangeNotifier {
  bool _showDialog = false;
  String _message = '';

  bool get showDialog => _showDialog;
  String get message => _message;

  void show(String message) {
    _showDialog = true;
    _message = message;
    notifyListeners();
  }

  void hide() {
    _showDialog = false;
    notifyListeners();
  }
}
