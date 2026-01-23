import 'package:flutter/material.dart';
import 'package:mesasnsps/model/provider/table_provider.dart';
import 'package:mesasnsps/screens/home_navigation_screen.dart';
import 'package:mesasnsps/screens/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Necessário para inicializar plugins antes do runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Verifica se a sessão expirou
  bool showWelcome = await checkSessionExpired();

  runApp(
    ChangeNotifierProvider(
      create: (context) => TableProvider(),
      child: MyApp(
        startScreen: showWelcome
            ? const WelcomeScreen()
            : const HomeNavigationScreen(),
      ),
    ),
  );
}

// Função para checar o tempo
Future<bool> checkSessionExpired() async {
  final prefs = await SharedPreferences.getInstance();
  final int? lastEntry = prefs.getInt('last_interaction');

  // Se for a primeira vez, mostra a tela de boas-vindas
  if (lastEntry == null) return true;

  final lastDate = DateTime.fromMillisecondsSinceEpoch(lastEntry);
  final difference = DateTime.now().difference(lastDate);

  // --- DEFINE O TEMPO AQUI ---
  // Exemplo: Se ficou mais de 2 horas (120 min) sem abrir, volta pro início
  return difference.inMinutes > 240;
}

class MyApp extends StatefulWidget {
  final Widget startScreen;
  const MyApp({super.key, required this.startScreen});

  @override
  State<MyApp> createState() => _MyAppState();
}

// Usamos WidgetsBindingObserver para detectar quando o app fecha/minimiza
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Sempre que o estado do app mudar (minimizar, fechar, voltar)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Quando o usuário sai do app, a gente salva o "carimbo" de hora
      _saveTimestamp();
    }
  }

  Future<void> _saveTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'last_interaction',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mesas NSPS',
      theme: ThemeData(useMaterial3: true),
      home: widget.startScreen,
    );
  }
}
