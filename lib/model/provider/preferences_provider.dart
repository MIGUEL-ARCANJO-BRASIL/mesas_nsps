import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesProvider with ChangeNotifier {
  bool _isTutorialEnabled = true;
  bool? _userChoiceMade;
  final Map<String, bool> _completedTutorials = {};

  PreferencesProvider() {
    _loadFromPrefs();
  }

  // Getters
  bool get isTutorialEnabled => _isTutorialEnabled;
  bool get isFirstTime => _userChoiceMade == null;

  /// Carrega as configurações salvas permanentemente no dispositivo
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isTutorialEnabled = prefs.getBool('tutorial_enabled') ?? true;
    _userChoiceMade = prefs.getBool('user_choice_made');
    notifyListeners();
  }

  /// Método exigido pelo WelcomeComponent para ativar/desativar o tour inicial
  Future<void> setTutorialMode(bool value) async {
    _isTutorialEnabled = value;
    _userChoiceMade = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_enabled', value);
    await prefs.setBool('user_choice_made', true);

    notifyListeners();
  }

  /// Verifica se um tutorial específico foi concluído (em memória nesta sessão)
  bool hasCompletedTutorial(String screenName) {
    return _completedTutorials[screenName] ?? false;
  }

  /// Marca um tutorial como concluído e salva a preferência se for o fluxo final
  Future<void> completeTutorial(String screenName) async {
    _completedTutorials[screenName] = true;

    // Se o usuário finalizou o tutorial da lista ('full_flow'), desativamos o modo tutorial globalmente
    if (screenName == 'full_flow') {
      await setTutorialMode(false);
    } else {
      notifyListeners();
    }
  }

  /// Atalho para desativar o tutorial (pode ser usado no onSkip ou botões de fechar)
  Future<void> disableTutorial() async {
    await setTutorialMode(false);
  }

  /// Atalho para reativar o tutorial (útil para uma tela de Ajustes/Configurações)
  Future<void> enableTutorial() async {
    await setTutorialMode(true);
  }
}
