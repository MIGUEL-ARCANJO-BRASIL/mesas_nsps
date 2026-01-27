import 'package:flutter/material.dart';

class PreferencesProvider with ChangeNotifier {
  bool _isTutorialEnabled = false;
  // Nova variável: se for null, significa que o usuário nunca escolheu nada
  bool? _userChoiceMade;

  final Map<String, bool> _completedTutorials = {};

  bool get isTutorialEnabled => _isTutorialEnabled;

  // Esse é o getter que estava faltando!
  // Se _userChoiceMade for null, então é a primeira vez (isFirstTime = true)
  bool get isFirstTime => _userChoiceMade == null;

  Future<void> setTutorialMode(bool value) async {
    _isTutorialEnabled = value;
    _userChoiceMade = true; // Agora o app sabe que o usuário já decidiu
    notifyListeners();
  }

  bool hasCompletedTutorial(String screenName) {
    return _completedTutorials[screenName] ?? false;
  }

  void completeTutorial(String screenName) {
    _completedTutorials[screenName] = true;
    notifyListeners();
  }
}
